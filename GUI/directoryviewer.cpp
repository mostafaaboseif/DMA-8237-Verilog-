#include "directoryviewer.h"
DirectoryViewer::DirectoryViewer(QWidget *parent):QTreeView(parent){
    fmodel = new QFileSystemModel(this);
    fmodel->setRootPath("/home/mgtm/Verilog/Mips");
    this->setModel(fmodel);
    this->setAnimated(true);
    this->setIndentation(15);
    this->setSortingEnabled(false);
    this->setRootIndex(fmodel->index("../assemblyCode/"));
    for (int i = 1; i < fmodel->columnCount(); ++i)
        this->hideColumn(i);
    this->header()->hide();
}

void DirectoryViewer::setHeader(QString title){
    fmodel->setHeaderData(0,Qt::Horizontal,title);
     this->header()->show();
}

QFileSystemModel* DirectoryViewer::getFileSystemModel(){
    return fmodel;
}
