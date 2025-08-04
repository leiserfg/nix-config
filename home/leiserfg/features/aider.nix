{ pkgs, ... }:
let
  yaml = pkgs.formats.yaml_1_2 { };
  models = [
    "gpt-4.1"
    "claude-sonnet-4"
  ];
  extra_params = {
    max_tokens = 80000;
    extra_headers = {
      User-Agent = "GithubCopilot/1.155.0";
      Editor-Plugin-Version = "copilot/1.155.0";
      Editor-Version = "vscode/1.85.1";
      Copilot-Integration-Id = "vscode-chat";
    };
  };
in
{
  home.packages = [ pkgs.aider-chat ];

  home.file.".aider.conf.yml".source = yaml.generate "aider-conf" {
    model = "github_copilot/claude-sonnet-4";
    show-model-warnings = false;
    auto-commits = false;
  };

  home.file.".aider.model.settings.yml".source = yaml.generate "aider-model-settings" (
    builtins.map (model: {
      name = "github_copilot/${model}";
      inherit extra_params;
    }) models
  );
}
