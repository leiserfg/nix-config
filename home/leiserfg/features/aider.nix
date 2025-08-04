{
  pkgs,
  home,
  lib,
  ...
}:
{

  home.sessionVariables.AIDER_MODEL = "github_copilot/claude-sonnet-4";
  home.packages = [
    pkgs.aider-chat
  ];

  home.file.".aider.model.settings.yml".source =
    (pkgs.formats.yaml_1_2 { }).generate "aider-models.yaml"
      (
        let
          extra_params = {
            max_tokens = 80000;
            extra_headers = {
              User-Agent = "GithubCopilot/1.155.0";
              Editor-Plugin-Version = "copilot/1.155.0";
              Editor-Version = "vscode/1.85.1";
              Copilot-Integration-Id = "copilot-chat";
            };
          };
        in
        (builtins.map
          (name: {
            name = "github_copilot/${name}";
            extra_params = extra_params;
          })
          [
            "o4-mini"
            "gemini-2.5-pro"
            "claude-sonnet-4"
            "gpt-4.1"
          ]
        )
      );

}
