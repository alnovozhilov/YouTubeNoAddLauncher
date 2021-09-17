import sys

from bs4 import BeautifulSoup as bs
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot

from PythonClasses.Channel import Channel
 
if __name__ == "__main__":

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    channel = Channel()
    engine.rootContext().setContextProperty("ch", channel)
    engine.load("main.qml")
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())