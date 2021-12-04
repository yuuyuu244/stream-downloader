import configparser as cp

class Conf():
    conf_path = 'stream-reader.conf'

    def __init__(self, conf_path: str) -> None:
        Conf.conf_path = conf_path
        self.options = {}
        self._read()
        self.get_all()
    
    def __init__(self) -> None:
        self.inst = cp.ConfigParser()
        self.options = {}
        self._read()
        self.get_all()

    def _read(self) -> None:
        self.inst.read(Conf.conf_path)
        self.get_all()
    
    def get(self, section: str, name: str) -> None:
        self.get(section, name)

    def get_all(self) -> None:
        self.sections = self.inst.sections()
        for section in self.sections:
            op = {}
            for option in self.inst.options(section):
                op[option] = self.inst.get(section, option)
            
            self.options[section] = op

    def print_conf(self):
        print(self.options)

    # 以下，個別に設定項目を取得するものを
    # アプリケーションごとに定義する

def main():
    config = Conf()
    config.print_conf()

if __name__ == "__main__":
    main()
