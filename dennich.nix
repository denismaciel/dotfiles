{python3Packages}:
python3Packages.buildPythonApplication {
  pname = "dennich";
  version = "1.0.0";
  format = "pyproject";
  src = ./python-packages/dennich;

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
