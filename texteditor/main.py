import sys
import time
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5 import QtCore
from PyQt5.QtCore import Qt
from PyQt5.uic.properties import QtGui
from codeeditor import *
import subprocess
import os
var = 0
f = ""
choiceStr = ""
cs = False
wwo = False

tt = True
tf = True
ts = True

curr_dir_path = os.path.dirname(os.path.realpath(__file__))  # Get current directory
executable_compiler_path = curr_dir_path + "/../src/compiler/clite"
save_same_file_opened = False
opened_file_path = None

wind_x, wind_y = (1000, 800)


class Find(QDialog):
    def __init__(self, parent=None):
        QDialog.__init__(self, parent)

        self.initUI()

    def initUI(self):

        self.lb1 = QLabel("Search for: ", self)
        self.lb1.setStyleSheet("font-size: 15px; ")
        self.lb1.move(10, 10)

        self.te = QTextEdit(self)
        self.te.move(10, 40)
        self.te.resize(250, 25)

        self.src = QPushButton("Find", self)
        self.src.move(270, 40)

        self.lb2 = QLabel("Replace all by: ", self)
        self.lb2.setStyleSheet("font-size: 15px; ")
        self.lb2.move(10, 80)

        self.rp = QTextEdit(self)
        self.rp.move(10, 110)
        self.rp.resize(250, 25)

        self.rpb = QPushButton("Replace", self)
        self.rpb.move(270, 110)

        self.opt1 = QCheckBox("Case sensitive", self)
        self.opt1.move(10, 160)
        self.opt1.stateChanged.connect(self.CS)

        self.opt2 = QCheckBox("Whole words only", self)
        self.opt2.move(10, 190)
        self.opt2.stateChanged.connect(self.WWO)

        self.close = QPushButton("Close", self)
        self.close.move(270, 220)
        self.close.clicked.connect(self.Close)

        self.setGeometry(300, 300, 600, 250)

    def CS(self, state):
        global cs

        if state == QtCore.Qt.Checked:
            cs = True
        else:
            cs = False

    def WWO(self, state):
        global wwo
        print(wwo)

        if state == QtCore.Qt.Checked:
            wwo = True
        else:
            wwo = False

    def Close(self):
        self.hide()


class Date(QDialog):
    def __init__(self, parent=None):
        QDialog.__init__(self, parent)

        self.initUI()

    def initUI(self):
        self.form = QComboBox(self)
        self.form.move(10, 10)
        self.form.addItem(time.strftime("%d.%m.%Y"))
        self.form.addItem(time.strftime("%A, %d. %B %Y"))
        self.form.addItem(time.strftime("%d. %B %Y"))
        self.form.addItem(time.strftime("%d %m %Y"))
        self.form.addItem(time.strftime("%X"))
        self.form.addItem(time.strftime("%x"))
        self.form.addItem(time.strftime("%H:%M"))
        self.form.addItem(time.strftime("%A, %d. %B %Y %H:%M"))
        self.form.addItem(time.strftime("%d.%m.%Y %H:%M"))
        self.form.addItem(time.strftime("%d. %B %Y %H:%M"))

        self.form.activated[str].connect(self.handleChoice)

        self.ok = QPushButton("Insert", self)
        self.ok.move(180, 10)

        self.cancel = QPushButton("Cancel", self)
        self.cancel.move(180, 40)
        self.cancel.clicked.connect(self.Cancel)

        self.setGeometry(300, 300, 280, 70)

    def handleChoice(self, choice):
        global choiceStr

        choiceStr = choice

        print(choiceStr)

    def Cancel(self):
        self.close()


class Main(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self, None)
        self.initUI()

    def initUI(self):

        # ------- Toolbar --------------------------------------

        # -- Upper Toolbar --

        newAction = QAction(QIcon("icons/new.png"), "New", self)
        newAction.setShortcut("Ctrl+N")
        newAction.setStatusTip("Create a new document from scratch.")
        newAction.triggered.connect(self.New)

        openAction = QAction(QIcon("icons/open.png"), "Open file", self)
        openAction.setStatusTip("Open existing document")
        openAction.setShortcut("Ctrl+O")
        openAction.triggered.connect(self.Open)

        saveAction = QAction(QIcon("icons/save.png"), "Save", self)
        saveAction.setStatusTip("Save document")
        saveAction.setShortcut("Ctrl+S")
        saveAction.triggered.connect(self.Save)

        findAction = QAction(QIcon("icons/find.png"), "Find", self)
        findAction.setStatusTip("Find words in your document")
        findAction.setShortcut("Ctrl+F")
        findAction.triggered.connect(self.Find)

        cutAction = QAction(QIcon("icons/cut.png"), "Cut to clipboard", self)
        cutAction.setStatusTip("Delete and copy text to clipboard")
        cutAction.setShortcut("Ctrl+X")
        cutAction.triggered.connect(self.Cut)

        copyAction = QAction(QIcon("icons/copy.png"), "Copy to clipboard", self)
        copyAction.setStatusTip("Copy text to clipboard")
        copyAction.setShortcut("Ctrl+C")
        copyAction.triggered.connect(self.Copy)

        pasteAction = QAction(QIcon("icons/paste.png"), "Paste from clipboard", self)
        pasteAction.setStatusTip("Paste text from clipboard")
        pasteAction.setShortcut("Ctrl+V")
        pasteAction.triggered.connect(self.Paste)

        undoAction = QAction(QIcon("icons/undo.png"), "Undo last action", self)
        undoAction.setStatusTip("Undo last action")
        undoAction.setShortcut("Ctrl+Z")
        undoAction.triggered.connect(self.Undo)

        redoAction = QAction(QIcon("icons/redo.png"), "Redo last undone thing", self)
        redoAction.setStatusTip("Redo last undone thing")
        redoAction.setShortcut("Ctrl+Y")
        redoAction.triggered.connect(self.Redo)

        dedentAction = QAction(QIcon("icons/dedent.png"), "Dedent Area", self)
        dedentAction.setShortcut("Shift+Tab")
        dedentAction.setStatusTip("dendent the selected row")
        dedentAction.triggered.connect(self.Dedent)

        compileAction = QAction(QIcon("icons/compile.png"), "Compile", self)
        compileAction.setShortcut("Ctrl+F5")
        compileAction.setStatusTip("Compile")
        compileAction.triggered.connect(self.Compile)

        self.toolbar = self.addToolBar("Options")
        self.toolbar.addAction(newAction)
        self.toolbar.addAction(openAction)
        self.toolbar.addAction(saveAction)
        self.toolbar.addSeparator()
        self.toolbar.addSeparator()
        self.toolbar.addAction(findAction)
        self.toolbar.addAction(cutAction)
        self.toolbar.addAction(copyAction)
        self.toolbar.addAction(pasteAction)
        self.toolbar.addAction(undoAction)
        self.toolbar.addAction(redoAction)
        self.toolbar.addAction(dedentAction)
        self.toolbar.addSeparator()
        self.toolbar.addSeparator()
        self.toolbar.addAction(compileAction)

        # ------- Text Edit -----------------------------------

        self.text = CodeEditor(self)
        self.text.setStyleSheet("background-color:  #2B2B2B; color:#BBBBBB;foreground-color:#A9B7C6;"
                                "font: 75 15pt Consolas;color: rgb(255, 255, 255);"
                                "font-weight:bold;")
        self.text.move(0, 100)

        self.text.resize(wind_x, int(wind_y * 1 / 2))
        self.text.setTabStopWidth(4)

        # ------- Compiler Output -----------------------------------

        self.compiler_output = QTextEdit(self)
        self.compiler_output.move(0, self.text.frameGeometry().height() + 100)
        self.compiler_output.resize(wind_x, int(wind_y / 2) - 120)
        self.compiler_output.setFont(QFont("DejaVu Sans Mono", 12))
        self.compiler_output.setFontPointSize(12)
        self.compiler_output.setStyleSheet("background-color:  #333131; color:white;"
                                           "")
        self.compiler_output.setReadOnly(True)

        # ------- Statusbar ------------------------------------

        self.status = self.statusBar()

        self.text.cursorPositionChanged.connect(self.CursorPosition)

        # ---------Window settings --------------------------------

        self.setGeometry(100, 100, wind_x, wind_y)
        self.setWindowTitle("Clite compiler")
        self.setWindowIcon(QIcon("icons/feather.png"))
        self.show()

        # ------- Menubar --------------------------------------

        menubar = self.menuBar()
        file = menubar.addMenu("File")
        edit = menubar.addMenu("Edit")
        view = menubar.addMenu("View")

        file.addAction(newAction)
        file.addAction(openAction)
        file.addAction(saveAction)

        edit.addAction(undoAction)
        edit.addAction(redoAction)
        edit.addAction(cutAction)
        edit.addAction(copyAction)
        edit.addAction(findAction)

        toggleTool = QAction("Toggle Toolbar", self, checkable=True)
        toggleTool.triggered.connect(self.handleToggleTool)

        toggleFormat = QAction("Toggle Formatbar", self, checkable=True)
        toggleFormat.triggered.connect(self.handleToggleFormat)

        toggleStatus = QAction("Toggle Statusbar", self, checkable=True)
        toggleStatus.triggered.connect(self.handleToggleStatus)

        view.addAction(toggleTool)
        view.addAction(toggleFormat)
        view.addAction(toggleStatus)

    def handleToggleTool(self):
        global tt

        if tt == True:
            self.toolbar.hide()
            tt = False
        else:
            self.toolbar.show()
            tt = True

    def handleToggleFormat(self):
        global tf

        if tf == True:
            self.formatbar.hide()
            tf = False
        else:
            self.formatbar.show()
            tf = True

    def handleToggleStatus(self):
        global ts

        if ts == True:
            self.status.hide()
            ts = False
        else:
            self.status.show()
            ts = True

            # -------- Toolbar slots -----------------------------------

    def New(self):
        global save_same_file_opened
        save_same_file_opened = False
        self.text.clear()

    def Open(self):
        filename = QFileDialog.getOpenFileName(self, 'Open File')[0]
        global opened_file_path
        global save_same_file_opened
        opened_file_path = filename
        save_same_file_opened = True
        print("file name: ", filename)
        f = open(filename, 'r')
        filedata = f.read()
        self.text.clear()
        self.text.appendPlainText(filedata)
        f.close()

    def Save(self):
        global save_same_file_opened
        global opened_file_path
        if save_same_file_opened:
            f = open(opened_file_path, 'w')
        else:
            filename = QFileDialog.getSaveFileName(self, 'Save File')[0]
            f = open(filename, 'w')
            opened_file_path = filename

        save_same_file_opened = True
        filedata = self.text.toPlainText()
        f.write(filedata)
        f.close()

    def PageView(self):
        preview = QPrintPreviewDialog()
        preview.paintRequested.connect(self.PaintPageView)
        preview.exec_()

    def Find(self):
        global f

        find = Find(self)
        find.show()

        def handleFind():

            f = find.te.toPlainText()
            print(f)

            if cs == True and wwo == False:
                flag = QTextDocument.FindBackward and QTextDocument.FindCaseSensitively

            elif cs == False and wwo == False:
                flag = QTextDocument.FindBackward

            elif cs == False and wwo == True:
                flag = QTextDocument.FindBackward and QTextDocument.FindWholeWords

            elif cs == True and wwo == True:
                flag = QTextDocument.FindBackward and QTextDocument.FindCaseSensitively and QTextDocument.FindWholeWords

            self.text.find(f, flag)

        def handleReplace():
            f = find.te.toPlainText()
            r = find.rp.toPlainText()

            text = self.text.toPlainText()

            newText = text.replace(f, r)

            self.text.clear()
            self.text.append(newText)

        find.src.clicked.connect(handleFind)
        find.rpb.clicked.connect(handleReplace)

    def Undo(self):
        self.text.undo()

    def Redo(self):
        self.text.redo()

    def Cut(self):
        self.text.cut()

    def Copy(self):
        self.text.copy()

    def Paste(self):
        self.text.paste()

    def CursorPosition(self):
        line = self.text.textCursor().blockNumber() + 1
        col = self.text.textCursor().columnNumber()
        linecol = ("Line: " + str(line) + " | " + "Column: " + str(col))
        self.status.showMessage(linecol)

    def Dedent(self):
        tab = "\t"
        cursor = self.text.textCursor()

        start = cursor.selectionStart()
        end = cursor.selectionEnd()

        cursor.setPosition(end)
        cursor.movePosition(cursor.EndOfLine)
        end = cursor.position()

        cursor.setPosition(start)
        cursor.movePosition(cursor.StartOfLine)
        start = cursor.position()

        while cursor.position() < end:
            global var

            cursor.movePosition(cursor.StartOfLine)
            cursor.deleteChar()
            cursor.movePosition(cursor.EndOfLine)
            cursor.movePosition(cursor.Down)
            end -= len(tab)

            '''if cursor.position() == end:
                var +=1
 
            if var == 2:
                break'''

    def Compile(self):
        self.compiler_output.clear()
        """
        Compile code
        """
        if opened_file_path == None:
            self.compiler_output.setFontPointSize(20)
            self.compiler_output.append("Save current file as it has not been written to disk yet")
            self.compiler_output.setStyleSheet("background-color:  #333131; color:red;"
                                               "")
            return

        compiler_input_file = opened_file_path
        compiler_output_file = QFileDialog.getSaveFileName(self, 'Save File')[0]

        subprocess.call([executable_compiler_path + "<" + compiler_input_file + ">" + compiler_output_file],
                        shell=True)

        f = open(compiler_output_file, 'r')
        filedata = f.read()


        self.compiler_output.setStyleSheet("background-color:  #333131; color:green;"
                                           "")
        # Bad thing to do: if line: exist then it is an error.
        if filedata.find("error") != -1:
            self.compiler_output.setStyleSheet("background-color:  #333131; color:red;"
                                               "")
        self.compiler_output.setFontPointSize(20)
        self.compiler_output.append("Compiler Output:")
        self.compiler_output.setFontPointSize(14)

        self.compiler_output.append(filedata)
        f.close()


def main():
    app = QApplication(sys.argv)
    main = Main()
    main.show()

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
