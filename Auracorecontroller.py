#Author:Chanapai Chuadchum
#Project:Auracore color controller GUI 
#release date:25/2/2020
from PyQt5 import QtCore, QtWidgets, uic,Qt,QtGui 
from PyQt5.QtWidgets import QApplication,QTreeView,QDirModel,QFileSystemModel,QVBoxLayout, QTreeWidget,QStyledItemDelegate, QTreeWidgetItem,QLabel,QGridLayout,QLineEdit,QDial
from PyQt5.QtWidgets import *
from PyQt5.QtGui import QPixmap,QIcon,QImage,QPalette,QBrush
from pyqtgraph.Qt import QtCore, QtGui   #PyQt graph to control the model grphic loaded  
import pyqtgraph.opengl as gl
import csv 
import os 
import sys 
class MainWindow(QtWidgets.QMainWindow):

    def __init__(self, *args, **kwargs):
        super(MainWindow, self).__init__(*args, **kwargs)

        #Load the UI Page
        uic.loadUi('Auracorecolor.ui', self)
        self.setWindowTitle('Aura core color ring')
        p = self.palette()
        p.setColor(self.backgroundRole(), QtCore.Qt.darkGray)
        self.setPalette(p)
        oImage = QImage("NeuralFuture.jpeg")
        #sImage = oImage.scaled(QSize(300,200))                   # resize Image to widgets size
        palette = QPalette()
        palette.setBrush(QPalette.Window, QBrush(oImage))
        self.setPalette(palette)
        #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
           # Dial set control for the dial 
        self.dial.setMinimum(0)
        self.dial.setMaximum(7)
        self.dial.setValue(0) # Set the value at the 0 
        self.dial.valueChanged.connect(self.Color)
    def Color(self): 
        print("Color number:= %i" % (self.dial.value())) 
        # Add the color list function here to run the color 
        Listcolor = ['black','white','blue','green','yellow','cyan','magenta','rainbow']   
        os.system("sudo rogauracore"+"\t"+str(Listcolor[int(self.dial.value())]))
        self.label_2.setText(str(Listcolor[int(self.dial.value())]))
        self.label_2.setStyleSheet("color:"+str(Listcolor[int(self.dial.value())]))
        

def main():
    app = QtWidgets.QApplication(sys.argv)
    main = MainWindow()
    main.show()
    sys.exit(app.exec_())

    
if __name__ == '__main__':         
    main()
