import pynvim


@pynvim.plugin
class NVLLM(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.config = nvim.exec_lua("return require('nvllm').get_config()")

    @pynvim.function("PythonTest")
    def python_test(self, args):
        self.nvim.command(
            f'echo "hello from PythonTest", config value: {self.config['value']}'
        )
