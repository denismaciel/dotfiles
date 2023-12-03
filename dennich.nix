{ lib, python3Packages, fetchFromGitHub, installShellFiles }:

python3Packages.buildPythonApplication rec {
  pname = "dennich";
  version = "1.32.0";
  format = "pyproject";

  # src = fetchFromGitHub {
  #   owner = "denismaciel";
  #   repo = "dennich";
  #   rev = "v2023-12-03.1";
  #   sha256 = ""; # TODO
  # };
  src = /home/denis/github.com/denismaciel/dennich;

  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  propagatedBuildInputs = with python3Packages; [

    # "pydantic",
    # "anki",
    # "markdownify",
    # "plumbum",
    # "pyfzf",
    # "openai",
    # "structlog",
    # "sqlalchemy",
    pydantic
    # anki
    markdownify
    plumbum
    pyfzf
    openai
    structlog
    sqlalchemy
    ];

  meta = with lib; {
    # description = "tmux session manager";
    # homepage = "https://tmuxp.git-pull.com/";
    # changelog = "https://github.com/tmux-python/tmuxp/raw/v${version}/CHANGES";
    # license = licenses.mit;
    # maintainers = with maintainers; [ peterhoeg ];
    # mainProgram = "tmuxp";
  };
}
