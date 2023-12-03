{ python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "dennich";
  version = "1.32.0";
  format = "pyproject";
  src = /home/denis/github.com/denismaciel/dennich;

  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  propagatedBuildInputs = with python3Packages; [
    pydantic
    markdownify
    plumbum
    pyfzf
    openai
    structlog
    sqlalchemy
  ];
}
