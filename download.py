import tkinter.ttk as ttk
import os
import conf

FOLDER_PATH = ""
SVR_PATH = ""
FFMPEG_PATH = "{}\\bin\\ffmpeg-4.3.1-2021-01-01-full_build\\bin".format(FOLDER_PATH)
HISTORY_PATH = ".\.history"
CHROME_PATH = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
ABEMATV_URL = "https://abema.tv/"
DAILY_URL = "https://www.dailymotion.com/"

# 作業ディレクトリを取得
# 特に変更する必要なし
CURRENT = os.getcwd()

# Open Folder Path
# ダウンロード先を指定
OPEN_FOLDER_PATH = "{}\movie".format(CURRENT)
print(OPEN_FOLDER_PATH)

# 環境変数の設定
os.environ['DOWNLOAD_DIR'] = CURRENT + "\\bin"
os.environ['STREAMLINK_DIR'] = CURRENT + "\\bin\\Streamlink"
os.environ['FFMPEG_DIR'] = FFMPEG_PATH

# Program name
# 特に変更する必要なし
PROGRAM_NAME = "Stream downloader"

class StreamUtil:
    @classmethod
    def rename(self, src, dst):
        import os
        os.rename(src, dst)

    @classmethod
    def convert_to_used_filename(self, filename: str) -> str:
        """
        Windowsでファイル名に使用できない禁止文字を全角に変換する
        """
        #cannotUsedFileName = '`">< 　・&#'
        #usedFileName = ''
        #usedFileName =       '`”＞＜__．＆＃'

        mappings = {
            '`':'‘', 
            ' ':'',
            '　':'',
            '&':'＆', 
            '<':'＜', 
            '>':'＞',
            '#':'＃',
            '\\':'￥',
            '.':'．',
            ':':'：'}
        rep_filename = filename
        import re
        for key, value in mappings.items():
            rep_filename = rep_filename.replace(key, value)

        #for num in range(0,len(cannotUsedFileName)-1):
        #    rep_filename = re.sub(cannotUsedFileName[num], usedFileName[num], rep_filename)
        if "_｜_無料動画．見逃し配信を見るなら_｜_ABEMA" in rep_filename:
            rep_filename = rep_filename[:(len(rep_filename) - 26)]
        if "_｜_無料で動画&見逃し配信を見るなら【ABEMAビデオ】" in rep_filename:
            rep_filename = rep_filename[:(len(rep_filename) - 27)]
        if "_｜_無料で動画&見逃し配信を見るなら【ABEMAビデオ】" in rep_filename:
            rep_filename = rep_filename[:(len(rep_filename) - 27)]
        if "_哔哩哔哩_bilibili" in rep_filename:
            rep_filename = rep_filename[:(len(rep_filename) - 14)]
        return rep_filename

    @classmethod
    def check_filename(self, filename: str) -> str:
        """
        ファイル名の長さチェック
        引数  ：filename ファイル名
        """
        MAX_FILE_NAME_LENGTH = 120
        if len(filename) > MAX_FILE_NAME_LENGTH:
            filename = filename[:MAX_FILE_NAME_LENGTH]
            print("[Info] 文字列縮小 :[" + filename + "]")
        
        return filename
    
    @classmethod
    def extraTitle(self, url: str) -> str:
        import urllib.request
        from bs4 import BeautifulSoup
        import ssl
        # 証明書チェック回避
        ssl._create_default_https_context = ssl._create_unverified_context

        html = urllib.request.urlopen(url)
        soup = BeautifulSoup(html, "html.parser")

        # タイトル要素の取得
        return soup.title.string # <title>ページタイトル</title>
    
    @classmethod
    def extra_title_now(self, url: str) -> str:
        """
        アベマ生配信用のタイトル取得
        """
        pass

    @classmethod
    def output_file(filename: str, log: str) -> None:
        """
        検索履歴出力用
        ファイル出力
        """
        pass

import tkinter as tk
class MyEntry(tk.Entry):
    """
    右クリックのエントリー
    Refs:https://qiita.com/ab-boy_ringo/items/874129f7d44c7cd6b4d5
    """
    def __init__(self, master, **kwargs):
        self.default_fontfamily = "Yu Gothic UI"
        self.default_fontsize = 10

        super().__init__(master, **kwargs)
        self.__create_menu()
        self.__bind_event()


    def __create_menu(self):
        self.menu = tk.Menu(self.master, tearoff=0, background="#111111", foreground="#eeeeee", activebackground="#000000", activeforeground="#ffffff")
        self.menu.add_command(label = "Cut", command=self.__on_cut, font=(self.default_fontfamily, self.default_fontsize))
        self.menu.add_command(label = "Copy", command=self.__on_copy, font=(self.default_fontfamily, self.default_fontsize))
        self.menu.add_command(label = "Paste", command=self.__on_paste, font=(self.default_fontfamily, self.default_fontsize))
        self.menu.add_command(label = "Delete", command=self.__on_delete, font=(self.default_fontfamily, self.default_fontsize))
        self.menu.add_separator()
        self.menu.add_command(label = "Select all", command=self.__on_select_all, font=(self.default_fontfamily, self.default_fontsize))


    def __on_cut(self):
        self.event_generate("<<Cut>>")


    def __on_copy(self):
        self.event_generate("<<Copy>>")


    def __on_paste(self):
        self.event_generate("<<Paste>>")


    def __on_delete(self):
        # from tkinter/constants.py
        #first = self.index(tk.SEL_FIRST)
        #last = self.index(tk.SEL_LAST)

        first = self.index("sel.first")
        last = self.index("sel.last")
        self.delete(first, last)


    def __on_select_all(self):
        self.select_range(0, "end")


    def __bind_event(self):
        self.bind("<Button-3>", self.__do_popup)


    def __do_popup(self, e):
        try:
            self.menu.tk_popup(e.x_root, e.y_root)
        finally:
            self.menu.grab_release()

import tkinter as tk
class Application(tk.Frame):
    button_col = 8
    text_span = 6
    def __init__(self, master) -> None:
        super().__init__(master,bg="#000000")
        #self.pack()

        self.master.geometry("575x350")
        self.master.resizable(width=False, height=False)
        self.master.configure(bg="#000000")
        self.master.title(PROGRAM_NAME)

        # ------------------------------
        # メニューバーの作成
        menubar = tk.Menu(self.master,bg="#000000",fg="#ffffff")

        filemenu = tk.Menu(menubar,bg="#000000",fg="#ffffff")
        filemenu.add_command(label="Open")
        filemenu.add_command(label="Save")
        filemenu.add_command(label="Exit")

        menubar.add_cascade(label="File", menu=filemenu)
        self.master.config(menu=menubar)
        # ------------------------------

        frame = tk.Frame(
            self.master,
            bg="#000000"
        )
        frame.pack()

        self.init_widget_m3u8(frame)
        self.init_widget_stream(frame)
        self.init_widget_live(frame)
        self.init_widget_copyright(frame) 
    
    def init_widget_m3u8(self, frame: tk.Frame) -> None:

        title = tk.Label(
            frame, 
            text="m3u8File", 
            width=10, 
            bg="#000000",
            fg="#ffffff",
            font=("Segoe UI Black", "10", "bold")
        )
        title.grid(row=0,column=0)


        label1 = tk.Label(
            frame, 
            text="m3u8File:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=1,column=0)

        mname = tk.Entry(
            frame,
            width="60"
        )
        mname.insert(0, "select m3u8 file")
        mname.grid(row=1,column=1,columnspan=Application.text_span)

        empty = tk.Label(
            frame, 
            text="", 
            width=1, 
            bg="#000000",
            fg="#ffffff"
        )
        empty.grid(row=1,column=7)

        sname = tk.Entry(
            frame,
            width="60"
        )
        sname.insert(0, "save name")
        sname.grid(row=2,column=1,columnspan=Application.text_span)

        def a():
            from tkinter import filedialog
            filetype = [("動画ファイル","*.m3u8"), ("すべて","*")]
            file_path = tk.filedialog.askopenfilename(initialdir = OPEN_FOLDER_PATH, filetypes = filetype)
            mname.delete(0,"end")
            mname.insert(0, file_path)
            sname.delete(0,"end")
            sname.insert(0, os.path.basename(file_path))

        obtn = tk.Button(
            frame,
            text="Open...",
            padx="10",
            width="10",
            command=a,
            bg="#000000",
            fg="#ffffff")
        obtn.grid(row=1,column=Application.button_col)

        
        label2 = tk.Label(
            frame, 
            text="saveName:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label2.grid(row=2,column=0)

        def click_sbtn() -> None:
            m3u8 = mname.get()
            m3u8_ = StreamUtil.convert_to_used_filename(os.path.basename((m3u8)))
            print(m3u8_)
            print(os.path.dirname(m3u8))
            m3u8_ = os.path.dirname(m3u8) + "/" + m3u8_
            print(m3u8_)
            StreamUtil.rename(m3u8, m3u8_)
            output = sname.get()
            import subprocess
 
            import ffmpeg
            try:
                subprocess.call("ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i {} -movflags faststart -c copy {}.mp4".format(m3u8_, output), shell=True)
                # stream = ffmpeg.input(m3u8_)
                # stream = ffmpeg.output("{}.mp4".format(output))
                # stream.run()
            except Exception as e:
                print(e)
                print("fail to download")
            pass

        sbtn = tk.Button(
            frame,
            text="download(m3u8)",
            width="10",
            padx="10",
            #pady="10",
            command=click_sbtn,
            bg="#000000",
            fg="#ffffff")
        
        sbtn.grid(row=2,column=Application.button_col)

        # 区切り線
        separator = ttk.Separator(frame)
        #separator.pack(fill="both")
        separator.grid(
            row=4, 
            column=0, 
            columnspan=9,
            sticky="ew",
            pady="10")

        # ------------------------------------------------------
        # -------------- URL download --------------------------
        # ------------------------------------------------------

    def init_widget_stream(self, frame: tk.Frame) -> None:
        base_row = 5
        title = tk.Label(
            frame, 
            text="Stream", 
            width=10, 
            bg="#000000",
            fg="#ffffff",
            font=("Segoe UI Black", "10", "bold")
        )
        title.grid(row=base_row,column=0)

        label1 = tk.Label(
            frame, 
            text="Url:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+1,column=0)

        # TODO
        # 履歴から取得する
        valuelist=['a', 'b']
        mname = ttk.Combobox(
            frame,
            width="57",
            values=valuelist
        )
        mname.insert(0, "select m3u8 file")
        mname.grid(row=base_row+1,column=1,columnspan=Application.text_span)

        empty = tk.Label(
            frame, 
            text="", 
            width=1, 
            bg="#000000",
            fg="#ffffff"
        )
        empty.grid(row=base_row+1,column=7)

        def a():
            # TODO
            # URLからタイトル取得
            pass

        obtn = tk.Button(
            frame,
            text="Extra Title",
            padx="10",
            width="10",
            command=a,
            bg="#000000",
            fg="#ffffff")
        obtn.grid(row=base_row+1,column=Application.button_col)

        label2 = tk.Label(
            frame, 
            text="saveName:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label2.grid(row=base_row+2,column=0)

        sname = tk.Entry(
            frame,
            width="60"
        )
        sname.insert(0, "save name")
        sname.grid(row=base_row+2,column=1,columnspan=Application.text_span)

        def click_sbtn() -> None:
            # streamlinkの呼び出し
            pass

        sbtn = tk.Button(
            frame,
            text="download",
            width="10",
            padx="10",
            command=click_sbtn,
            bg="#000000",
            fg="#ffffff")
        
        sbtn.grid(row=base_row+2,column=Application.button_col)

        # 区切り線
        separator = ttk.Separator(frame)
        #separator.pack(fill="both")
        separator.grid(
            row=base_row+3, 
            column=0, 
            columnspan=9,
            sticky="ew",
            pady="10")

    def init_widget_live(self, frame: tk.Frame) -> None:
        base_row = 10
        title = tk.Label(
            frame, 
            text="Live Stream", 
            width=10, 
            bg="#000000",
            fg="#ffffff",
            font=("Segoe UI Black", "10", "bold")
        )
        title.grid(row=base_row,column=0)
        
        label1 = tk.Label(
            frame, 
            text="Live Url:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+1,column=0)

        valuelist=[
            "https://abema.tv/now-on-air/abema-news", 
            "https://abema.tv/now-on-air/news-plus",
            "https://abema.tv/now-on-air/abema-special",
            "https://abema.tv/now-on-air/special-plus",
            "https://abema.tv/now-on-air/special-plus-2"]
        mname = ttk.Combobox(
            frame,
            width="57",
            values=valuelist
        )
        mname.insert(0, "https://abema.tv/now-on-air/special-plus")
        mname.grid(row=base_row+1,column=1,columnspan=Application.text_span)

        def extra_title():
            """
            タイトルを取得する
            """
            pass
        obtn = tk.Button(
            frame,
            text="Extra Title",
            padx="10",
            width="10",
            command=extra_title,
            bg="#000000",
            fg="#ffffff")
        obtn.grid(row=base_row+1,column=Application.button_col)

        label1 = tk.Label(
            frame, 
            text="Save Time:", 
            width=10, 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+2,column=0)


        valuelist=[]
        for item in range(0, 10 + 1):
            valuelist.append(str(item).zfill(2))

        mname = ttk.Combobox(
            frame,
            width="10",
            values=valuelist
        )
        mname.insert(0, "00")
        mname.grid(row=base_row+2,column=1)

        label1 = tk.Label(
            frame, 
            text="H", 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+2,column=2)

        valuelist=[]
        for item in range(0, 60):
            valuelist.append(str(item).zfill(2))

        mname = ttk.Combobox(
            frame,
            width="10",
            values=valuelist
        )
        mname.insert(0, "00")
        mname.grid(row=base_row+2,column=3)

        label1 = tk.Label(
            frame, 
            text="m", 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+2,column=4)

        valuelist=[]
        for item in range(0, 60):
            valuelist.append(str(item).zfill(2))

        mname = ttk.Combobox(
            frame,
            width="10",
            values=valuelist
        )
        mname.insert(0, "00")
        mname.grid(row=base_row+2,column=5)

        label1 = tk.Label(
            frame,
            text="s", 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+2,column=6)

        
        label1 = tk.Label(
            frame,
            text="Save Name:", 
            bg="#000000",
            fg="#ffffff"
        )
        label1.grid(row=base_row+3,column=0)

        mname = ttk.Combobox(
            frame,
            width="57",
            values=valuelist
        )
        mname.insert(0, "input save name")
        mname.grid(row=base_row+3,column=1, columnspan=Application.text_span)

        def download_live():
            """
            タイトルを取得する
            """
            pass
        obtn = tk.Button(
            frame,
            text="Download",
            padx="10",
            width="10",
            command=download_live,
            bg="#000000",
            fg="#ffffff")
        obtn.grid(row=base_row+3,column=Application.button_col)

        # 区切り線
        separator = ttk.Separator(frame)
        #separator.pack(fill="both")
        separator.grid(
            row=base_row+4, 
            column=0, 
            columnspan=9,
            sticky="ew",
            pady="10")

    def init_widget_copyright(self, frame: tk.Frame) -> None:
        base_row = 15
        copyright = tk.Label(
            frame, 
            text="Copyright © Yuki-Kikuya, 2019-2021", 
            width=70, 
            bg="#000000",
            fg="#ffffff",
            font=("Segoe UI Black", "10", "bold")
        )
        copyright.grid(row=base_row, column=0, columnspan=9)

def main() -> None:
    """
    root function
    """
    config = conf.Conf()
    FOLDER_PATH = config.options['common']['folder_path']
    SVR_PATH = config.options['common']['svr_path']
    FFMPEG_PATH = config.options['common']['ffmpeg_path']
    HISTORY_PATH = config.options['common']['history_path']

    ABEMATV_URL = config.options['urls']['abematv_url']
    DAILY_URL = config.options['urls']['daily_url']

    win = tk.Tk()
    app = Application(master=win)
    app.mainloop()

if __name__ == "__main__":
    main()