from elixir.compilers import ModelCompiler
from elixir.processors import NevermoreProcessor

ModelCompiler("src/", "model.rbxmx", NevermoreProcessor).compile()
