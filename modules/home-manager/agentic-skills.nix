{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  skillModule =
    { config, name, ... }:
    {

      options = {
        name = mkOption {
          type = types.str;
          description = "Skill name.";
          default = name;
        };
        description = mkOption {
          type = types.str;
          description = "Skill description.";
        };
        resources = mkOption {
          type = types.attrsOf types.path;
          description = "Resource set, alias → path (binaries, docs, etc.).";
        };
        instructions = mkOption {
          type = types.functionTo types.str;
          description = "Function: aliases → markdown for SKILL.md";
        };
      };
    };
in
{
  options.skills = {
    root = mkOption {
      type = types.str;
      default = ".pi/agent/skills";
      description = "Subdirectory under home to store agentic skills (e.g. '.pi/agent/skills').";
    };
    entries = mkOption {
      type = types.attrsOf (types.submodule skillModule);
      default = { };
      description = "Agentic skills entries.";
    };
  };

  config =
    let
      skillsRoot = "${config.home.homeDirectory}/${config.skills.root}";
      skillsEntries = config.skills.entries;
      validSkillName = name: builtins.match "^[a-z0-9-]+$" name != null;
      badNames = lib.filter (n: !validSkillName n) (lib.attrNames skillsEntries);
      # For each skill: create folder, SKILL.md, and symlinks or links to resources
      skillsRenderings = mapAttrsToList (
        skillName: skill:
        let
          folder = "${skillsRoot}/${skillName}";
          # Make the aliases map for passing to instructions (./alias form)
          aliasRelPath = lib.mapAttrs (k: _: "{baseDir}/${k}") skill.resources;
          # Link name to target path
          links = mapAttrsToList (alias: resPath: {
            name = "${folder}/${alias}";
            value = resPath;
          }) skill.resources;
          # Render SKILL.md with YAML frontmatter
          skillMd = ''
            ---
            name: ${skill.name}
            description: ${skill.description}
            ---
            '' + (skill.instructions aliasRelPath);

        in
        {
          files = [
            {
              target = "${folder}/SKILL.md";
              text = skillMd;
            }
          ];
          links = links;
        }
      ) skillsEntries;
      allLinks = concatMap (x: x.links) skillsRenderings;
      allFiles = concatMap (x: x.files) skillsRenderings;
    in
    {
      assertions = [
        {
          assertion = badNames == [];
          message = "Invalid skill name(s): ${lib.concatStringsSep ", " badNames} (only a-z, 0-9 and hyphens allowed)";
        }
      ];
      home.file = listToAttrs (
        (map (l: {
          name = lib.removePrefix (toString config.home.homeDirectory) l.name;
          value = {
            source = l.value;
            executable = true;
          };
        }) allLinks)
        ++ (map (f: {
          name = lib.removePrefix (toString config.home.homeDirectory) f.target;
          value = {
            text = f.text;
          };
        }) allFiles)
      );
    };
}
