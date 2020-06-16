#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent):QMainWindow(parent){

    tabWidget = new QTabWidget();
    simulationTabWidget = new QTabWidget();
    hSplitter = new QSplitter(Qt::Horizontal);
    subhSplitter = new QSplitter(Qt::Horizontal);
    vSplitter = new QSplitter(Qt::Vertical);
    dViewer = new DirectoryViewer();
    editors = new QMap<QString,Editor*>;
    files = new QMap<QString,QFile*>;
    paths = new QMap<QString,QString>;
    editorZoomValue = new QMap<QString,int>;
    regFileInfo = new QTableWidget(this);
    dmaMemInfo = new QTableWidget(this);
    ioInfo = new QTableWidget(this);
    ioInfo2 = new QTableWidget(this);
    ioInfo3 = new QTableWidget(this);
    ramInfo = new QTableWidget(this);
    instMemInfo = new QTableWidget(this);
    dataMemInfo = new QTableWidget(this);
    saveShortcut = new QShortcut(QKeySequence("Ctrl+s"), this);
    openShortcut = new QShortcut(QKeySequence("Ctrl+o"), this);
    compileShortcut = new QShortcut(QKeySequence("Ctrl+e"), this);
    runShortcut = new QShortcut(QKeySequence("Ctrl+r"), this);
    zoomInShortcut = new QShortcut(QKeySequence("Ctrl++"), this);
    zoomOutShortcut = new QShortcut(QKeySequence("Ctrl+-"), this);
    outputTabWidget = new QTabWidget(this);
    outputTextMap = new QMap<QString, QPlainTextEdit*>;
    status = new QStatusBar();
    dmaConfig = new DmaConfig();

    dViewer->setMaximumWidth(185);
    tabWidget->setMinimumWidth(680);
    simulationTabWidget->setMaximumWidth(480);
    hSplitter->addWidget(dViewer);
    hSplitter->addWidget(vSplitter);
    hSplitter->addWidget(simulationTabWidget);
    vSplitter->addWidget(tabWidget);
    vSplitter ->addWidget(outputTabWidget);
    vSplitter->addWidget(status);
    simulationTabWidget->addTab(regFileInfo,"Registers");
    simulationTabWidget->addTab(instMemInfo,"Instruction Mem");
    simulationTabWidget->addTab(dataMemInfo,"Data Mem");
    simulationTabWidget->addTab(dmaMemInfo,"DMA Registers");
    simulationTabWidget->addTab(ramInfo,"RAM");
    simulationTabWidget->addTab(ioInfo,"I/O - 0");
    simulationTabWidget->addTab(ioInfo2,"I/O - 1");
    simulationTabWidget->addTab(ioInfo3,"I/O - 2");
    outputTabWidget->setMaximumHeight(200);
    outputTabWidget->resize(100,100);
    outputTabWidget->setGeometry(0,0,outputTabWidget->width(),0);
    initMenus();
    initToolBar();
    initRegfileTable();
    initDmaMemTable();
    initInstMemTable();
    initDataMemTable();
    initRamTable();
    initIOTable();
    initIOTable2();
    initIOTable3();
    status->setMaximumHeight(10);
    tabWidget->setTabsClosable(true);
    outputTabWidget->setTabsClosable(true);

    this->setCentralWidget(hSplitter);
    this->showMaximized();

    connect(dViewer,SIGNAL(doubleClicked(QModelIndex)),this,SLOT(dViewerDoubleClick(QModelIndex)));
    connect(tabWidget, SIGNAL(tabCloseRequested(int)), this, SLOT(closeTab(int)));
    connect(outputTabWidget, SIGNAL(tabCloseRequested(int)), this, SLOT(closeOutputTab(int)));
    connect(saveShortcut, SIGNAL(activated()), this, SLOT(saveFile()));
    connect(openShortcut, SIGNAL(activated()), this, SLOT(openFile()));
    connect(compileShortcut, SIGNAL(activated()), this, SLOT(compileFile()));
    connect(runShortcut, SIGNAL(activated()), this, SLOT(runFile()));
    connect(zoomInShortcut, SIGNAL(activated()), this, SLOT(zoomIn()));
    connect(zoomOutShortcut, SIGNAL(activated()), this, SLOT(zoomOut()));
    connect(dmaConfig, &DmaConfig::generated, this, &MainWindow::setGeneratedCode);
}

void MainWindow::initToolBar(){
    toolBar = addToolBar("main tool bar");
    QPixmap openpix("/home/mgtm/Pictures/icons/open.svg");
    QPixmap newpix("/home/mgtm/Pictures/icons/new.svg");
    QPixmap savepix("/home/mgtm/Pictures/icons/save.svg");
    QPixmap compilepix("/home/mgtm/Pictures/icons/compile.svg");
    QPixmap runpix("/home/mgtm/Pictures/icons/run.svg");
    QPixmap settingpix("/home/mgtm/Pictures/icons/setting.svg");
    newAction = toolBar->addAction(QIcon(newpix),"New");
    openAction = toolBar->addAction(QIcon(openpix),"Open");
    saveAction = toolBar->addAction(QIcon(savepix),"Save");
    compileAction = toolBar->addAction(QIcon(compilepix),"Compile");
    runAction = toolBar->addAction(QIcon(runpix),"Run");
    dmaConfigAction = toolBar->addAction(QIcon(settingpix),"DMA Config");
    toolBar->setStyleSheet("QToolButton {padding: 5px 5px 15px 15px;}");

    connect(newAction,SIGNAL(triggered()),this,SLOT(newFile()));
    connect(openAction,SIGNAL(triggered()),this,SLOT(openFile()));
    connect(saveAction,SIGNAL(triggered()),this,SLOT(saveFile()));
    connect(compileAction,SIGNAL(triggered()),this,SLOT(compileFile()));
    connect(runAction,SIGNAL(triggered()),this,SLOT(runFile()));
    connect(dmaConfigAction,SIGNAL(triggered()),this,SLOT(dmaConfigShow()));
}

void MainWindow::initMenus(){
    file = menuBar()->addMenu("&File");
    quit = new QAction("&Quit",file);
    file->addAction(quit);
}

void MainWindow::openFile(){
    QString assemblyFilePath = QFileDialog::getOpenFileName(this,tr("Open Assembly File"), "/home/", tr("Assembly Files (*.asm)"));
    if(!assemblyFilePath.isEmpty()){
        std::string name = assemblyFilePath.toStdString();
        size_t index1 = name.find_last_of('/');
        size_t index2 = name.find_last_of(".asm");
        QString assemblyFileName =  QString::fromStdString(name.substr(index1+1,index2-index1-4));
        QFile *activeFile = new QFile(assemblyFilePath,this);
        activeFile->open(QIODevice::Text | QIODevice::ReadWrite);
        QString content;
        while(!activeFile->atEnd())content.append(activeFile->readLine());
        Editor *e = new Editor(this);
        editors->insert(assemblyFileName,e);
        editorZoomValue->insert(assemblyFileName,1);
        e->setPlainText(content);
        tabWidget->addTab(e,assemblyFileName);
        files->insert(assemblyFileName,activeFile);
        paths->insert(assemblyFileName,assemblyFilePath);
    }
}

void MainWindow::newFile(){
    bool ok;
    QString newFileName = QInputDialog::getText(this, tr("Create new File"),tr("File name :"), QLineEdit::Normal,"newAsemblyFile", &ok);
    if (ok && !newFileName.isEmpty()){
        QString newFileWithExt = newFileName;
        newFileWithExt += ".asm";
        qDebug() << newFileName;
        QString newFilePath = QFileDialog::getExistingDirectory(this,tr("Save File Location"), "/home/",QFileDialog::ShowDirsOnly|QFileDialog::DontResolveSymlinks);
        if(!newFilePath.isEmpty()){
            QString assemblyFilePath = newFilePath+"/"+newFileWithExt;
            QFile *currentFile = new QFile(assemblyFilePath,this);
            currentFile->open(QIODevice::Text | QIODevice::ReadWrite);
            files->insert(newFileName,currentFile);
            paths->insert(newFileName,assemblyFilePath);
            Editor *e = new Editor(this);
            editors->insert(newFileName,e);
            editorZoomValue->insert(newFileName,1);
            e->setPlainText("");
            tabWidget->addTab(e,newFileName);
        }
    }
}

void MainWindow::dmaConfigShow(){
    dmaConfig->show();
}

void MainWindow::saveFile(){
    if(getActiveEditor().compare("")){
        QFile *activeFile = files->value(getActiveEditor());
        activeFile->resize(0);
        activeFile->write(editors->find(getActiveEditor()).value()->toPlainText().toUtf8());
        activeFile->close();
        activeFile->open(QIODevice::Text | QIODevice::ReadWrite);
        status->showMessage("File Saved to "+getActiveEditor()+".asm",1000);
    }
}

void MainWindow::compileFile(){
    assemblerProcess = new QProcess();
    assemblerProcess->setProcessChannelMode(QProcess::MergedChannels);
    QString assemblyFilePath = paths->value(getActiveEditor());
    assemblerProcess->start("./../assembler_python/assembler.py "+assemblyFilePath+" ../biteCode/"+getActiveEditor()+".txt");
    qDebug() << "./../assembler_python/assembler.py "+assemblyFilePath+" ../biteCode/"+getActiveEditor()+".txt";
    assemblerProcess->waitForFinished(-1);
    QString output = assemblerProcess->readAll();
    status->showMessage("File assembled sucessfully !!!",1000);
}

void MainWindow::closeTab(int index){
    QString editorName = tabWidget->tabText(index);
    qDebug() << "editorName " << editorName;
    if(editorName == runningEditorName){
       closeSimulation();
    }
    QFile *f = files->value(editorName);
    f->close();
    delete f;
    editors->remove(editorName);
    files->remove(editorName);
    paths->remove(editorName);
    tabWidget->removeTab(index);
}

QString MainWindow::getActiveEditor(){
    return tabWidget->tabText(tabWidget->currentIndex());
}

void MainWindow::dViewerDoubleClick(QModelIndex modelIndex){
    QString path = dViewer->getFileSystemModel()->filePath(modelIndex);
    if(!path.right(3).compare("asm")){
        QString assemblyFilePath = path;
        std::string name = assemblyFilePath.toStdString();
        size_t index1 = name.find_last_of('/');
        size_t index2 = name.find_last_of(".asm");
        QString assemblyFileName =  QString::fromStdString(name.substr(index1+1,index2-index1-4));
        QFile *activeFile = new QFile(assemblyFilePath,this);
        activeFile->open(QIODevice::Text | QIODevice::ReadWrite);
        QString content;
        while(!activeFile->atEnd())content.append(activeFile->readLine());
        Editor *e = new Editor(this);
        editors->insert(assemblyFileName,e);
        e->setPlainText(content);
        tabWidget->addTab(e,assemblyFileName);
        files->insert(assemblyFileName,activeFile);
        paths->insert(assemblyFileName,assemblyFilePath);
    }
}

void MainWindow::initDataMemTable(){
    dataMemInfo->setRowCount(8192);
    dataMemInfo->setColumnCount(2);
    dataMemInfo->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    dataMemInfo->verticalHeader()->setVisible(false);
    dataMemInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    dataMemInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    dataMemInfo->setAlternatingRowColors(true);
    for (int i = 0; i < 8192; i++) {
        dataMemInfo->setItem(i, 0, new QTableWidgetItem(QString::number(i)));
        dataMemInfo->setItem(i, 1,  new QTableWidgetItem("00000000000000000000000000000000"));
    }
    dataMemInfo->setMinimumWidth(420);
    dataMemInfo->setColumnWidth(0,60);
    dataMemInfo->setColumnWidth(1,420);
    dataMemInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initRegfileTable(){
    regFileInfo->setRowCount(32);
    regFileInfo->setColumnCount(3);
    regFileInfo->setHorizontalHeaderLabels(QStringList({"Name","Number","Value"}));
    regFileInfo->verticalHeader()->setVisible(false);
    regFileInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    regFileInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    regFileInfo->setAlternatingRowColors(true);
    for (int i = 0; i < 32; i++) {
        regFileInfo->setItem(i, 0, new QTableWidgetItem(regNames[i]));
        regFileInfo->setItem(i, 1, new QTableWidgetItem(QString::number(i)));
        regFileInfo->setItem(i, 2,  new QTableWidgetItem("00000000000000000000000000000000"));
    }
    regFileInfo->setColumnWidth(0,60);
    regFileInfo->setColumnWidth(1,60);
    regFileInfo->setColumnWidth(2,350);
    regFileInfo->setMinimumWidth(420);
    regFileInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initDmaMemTable(){
    dmaMemInfo->setRowCount(16);
    dmaMemInfo->setColumnCount(2);
    dmaMemInfo->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    dmaMemInfo->verticalHeader()->setVisible(false);
    dmaMemInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    dmaMemInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    dmaMemInfo->setAlternatingRowColors(true);
    for (int i = 0; i < 17; i++) {
        dmaMemInfo->setItem(i, 0, new QTableWidgetItem(dmaRegs[i]));
    }
    dmaMemInfo->setMinimumWidth(420);
    dmaMemInfo->setColumnWidth(0,60);
    dmaMemInfo->setColumnWidth(1,410);
    dmaMemInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initRamTable(){
    ramInfo->setRowCount(15);
    ramInfo->setColumnCount(2);
    ramInfo->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    ramInfo->verticalHeader()->setVisible(false);
    ramInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    ramInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ramInfo->setAlternatingRowColors(true);
    for (int i = 0; i < 15; i++) {
        ramInfo->setItem(i, 0, new QTableWidgetItem(QString::number(i)));
        ramInfo->setItem(i, 1, new QTableWidgetItem("00000000"));
    }
    ramInfo->setMinimumWidth(420);
    ramInfo->setColumnWidth(0,60);
    ramInfo->setColumnWidth(1,420);
    ramInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initIOTable(){
    ioInfo->setRowCount(15);
    ioInfo->setColumnCount(2);
    ioInfo->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    ioInfo->verticalHeader()->setVisible(false);
    ioInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    ioInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ioInfo->setAlternatingRowColors(true);
    for (int i = 0; i < 15; i++) {
        ioInfo->setItem(i, 0, new QTableWidgetItem(QString::number(i)));
        ioInfo->setItem(i, 1, new QTableWidgetItem("00000000"));
    }
    ioInfo->setMinimumWidth(420);
    ioInfo->setColumnWidth(0,60);
    ioInfo->setColumnWidth(1,420);
    ioInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initIOTable2(){
    ioInfo2->setRowCount(15);
    ioInfo2->setColumnCount(2);
    ioInfo2->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    ioInfo2->verticalHeader()->setVisible(false);
    ioInfo2->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    ioInfo2->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ioInfo2->setAlternatingRowColors(true);
    for (int i = 0; i < 15; i++) {
        ioInfo2->setItem(i, 0, new QTableWidgetItem(QString::number(i)));
        ioInfo2->setItem(i, 1, new QTableWidgetItem("00000000"));
    }
    ioInfo2->setMinimumWidth(420);
    ioInfo2->setColumnWidth(0,60);
    ioInfo2->setColumnWidth(1,420);
    ioInfo2->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::initIOTable3(){
    ioInfo3->setRowCount(15);
    ioInfo3->setColumnCount(2);
    ioInfo3->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    ioInfo3->verticalHeader()->setVisible(false);
    ioInfo3->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    ioInfo3->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ioInfo3->setAlternatingRowColors(true);
    for (int i = 0; i < 15; i++) {
        ioInfo3->setItem(i, 0, new QTableWidgetItem(QString::number(i)));
        ioInfo3->setItem(i, 1, new QTableWidgetItem("00000000"));
    }
    ioInfo3->setMinimumWidth(420);
    ioInfo3->setColumnWidth(0,60);
    ioInfo3->setColumnWidth(1,420);
    ioInfo3->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}


void MainWindow::initInstMemTable(){
    instMemInfo->setRowCount(8191);
    instMemInfo->setColumnCount(2);
    instMemInfo->setHorizontalHeaderLabels(QStringList({"Address","Value"}));
    instMemInfo->verticalHeader()->setVisible(false);
    instMemInfo->setColumnWidth(0,50);
    instMemInfo->setStyleSheet("QTableView {selection-background-color: grey;alternate-background-color: rgb(218, 220, 224);}");
    instMemInfo->setEditTriggers(QAbstractItemView::NoEditTriggers);
    instMemInfo->setAlternatingRowColors(true);
    instMemInfo->setColumnWidth(0,60);
    instMemInfo->setColumnWidth(1,420);
    for (int i = 0; i < 8191; i++) {
        instMemInfo->setItem(i, 0, new QTableWidgetItem("0x"+QString::number(i,16)));
    }
    instMemInfo->setMinimumWidth(420);
    instMemInfo->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
}

void MainWindow::runFile(){
    if(!running){
        if(getActiveEditor().compare("")){
            saveFile();
            compileFile();
            status->showMessage("Running "+getActiveEditor()+".asm");
            runProcess = new QProcess(this);
            runProcess->start("cp ../biteCode/"+getActiveEditor()+".txt"+" ../biteCode/verilogRunFile.txt");
            qDebug() << "cp ../biteCode/"+getActiveEditor()+".txt"+" ../biteCode/verilogRunFile.txt";
            runProcess->waitForFinished(-1);
            fillInstMemTable();
            runProcess = new QProcess(this);
            runProcess->start("./../Verilog/run.sh");
            runProcess->waitForFinished(-1);
            runningEditor = editors->value(getActiveEditor());
            runningEditorName = getActiveEditor();
            runningEditor->setReadOnly(true);
            runningEditor->mapLineToInst(runningEditor->document()->lineCount());
            showSimTools();
            simulate();
            QPlainTextEdit *output = new QPlainTextEdit(outputTabWidget);
            outputTextMap->insert(runningEditorName,output);
            output->setReadOnly(true);
            outputTabWidget->addTab(output,getActiveEditor()+" [OUTPUT]");
            running = true;
        }
    }
}

void MainWindow::simulateSingleCycle(){
    QFile *f = new QFile("../Verilog/out.txt");
    f->open(QIODevice::ReadOnly);
    QTextStream in(f);
    while (!in.atEnd()){
       std::string line = in.readLine().toStdString();
       qDebug() << QString::fromStdString(line);
        size_t index1 = line.find("[");
        size_t index2 = line.find("]");
        QString type = QString::fromStdString(line.substr(index1+1,index2-index1-1));
        if(!type.compare("Reg Init")){
            size_t index1 = 13, index2;
            for(int a = 0; a < 32; a++){
                index2 = line.find(",",index1);
                QString i = QString::fromStdString(line.substr(index1+1,index2-index1-1));
                regFileInfo->setItem(a, 2, new QTableWidgetItem(i));
                index1 = index2+1;
            }
        }if(!type.compare("Ram Init")){
            size_t index1 = 13, index2;
            for(int a = 0; a < 16; a++){
                index2 = line.find(",",index1);
                QString i = QString::fromStdString(line.substr(index1+1,index2-index1-1));
                ramInfo->setItem(a, 1, new QTableWidgetItem(i));
                index1 = index2+1;
            }
        }if(!type.compare("IO Init")){
            size_t index1 = 13, index2;
            for(int a = 0; a < 16; a++){
                index2 = line.find(",",index1);
                QString i = QString::fromStdString(line.substr(index1+1,index2-index1-1));
                ioInfo->setItem(a, 1, new QTableWidgetItem(i));
                index1 = index2+1;
            }
        }else if(!type.compare("Data Memory")){
            size_t index1, index2;
            index1 = line.find("PC")+3;
            index2 = line.find(",",index1);
            QString pc = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("memAdress")+10;
            index2 = line.find(",",index1);
            QString addr = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("value")+6;
            index2 = line.find(",",index1);
            QString value = QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[3];
            m[0] = pc;
            m[1] = addr;
            m[2] = value;
            memValues_CLK_Forward->insert(clk,m);
        }else if(!type.compare("Reg File")){
            size_t index1, index2;
            index1 = line.find("PC")+3;
            index2 = line.find(",",index1);
            QString pc = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("regNumber")+10;
            index2 = line.find(",",index1);
            QString reg = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("regValue")+9;
            index2 = line.find(",",index1);
            QString value = QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[3];
            m[0] = pc;
            m[1] = reg;
            m[2] = value;
            regValues_CLK_Forward->insert(clk,m);
        }else if(!type.compare("RAM")){
            size_t index1, index2;
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("addr")+5;
            index2 = line.find(",",index1);
            QString addr = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("value")+6;
            index2 = line.find(",",index1);
            QString value = QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[2];
            m[0] = addr;
            m[1] = value;
            ramValues_CLK_Forward->insert(clk,m);
        }else if(!type.compare("IO")){
            size_t index1, index2;
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("addr")+5;
            index2 = line.find(",",index1);
            QString addr = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("value")+6;
            index2 = line.find(",",index1);
            QString value = QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[2];
            m[0] = addr;
            m[1] = value;
            ioValues_CLK_Forward->insert(clk,m);
        }else if(!type.compare("DMA")){
            size_t index1, index2;
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("type")+7;
            index2 = line.find(",",index1);
            QString type = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("value")+6;
            index2 = line.find(",",index1);
            QString value = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("addr")+5;
            index2 = line.find(",",index1);
            QString addr = QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[3];
            m[0] = value;
            m[1] = addr;
            if(!dmaValues_CLK_Forward->contains(clk)){
                QList <QString*> *dmaList = new QList<QString*>();
                dmaList->append(m);
                dmaValues_CLK_Forward->insert(clk,dmaList);
            }else{
                 dmaValues_CLK_Forward->value(clk)->append(m);
            }
        }else if(!type.compare("branch")){
            size_t index1, index2;
            index1 = line.find("PC")+3;
            index2 = line.find(",",index1);
            QString pc = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            QString *m = new QString[3];
            m[0] = pc;
            m[1] = "0";
            m[2] = "0";
            regValues_CLK_Forward->insert(clk,m);
        }else if(!type.compare("syscall")){
            size_t index1, index2;
            index1 = line.find("PC")+3;
            index2 = line.find(",",index1);
            QString pc = QString::fromStdString(line.substr(index1,index2-index1));
            index1 = line.find("clk")+4;
            index2 = line.find(",",index1);
            int clk = QString::fromStdString(line.substr(index1,index2-index1)).toInt();
            max_CLK = clk;
            index1 = line.find("output")+7;
            index2 = line.find(",",index1);
            QString output =  QString::fromStdString(line.substr(index1,index2-index1));
            QString *m = new QString[2];
            m[0] = pc;
            m[1] = "[PC::" + pc +"]: " + output;
            output_CLK_Forward->insert(clk,m);
        }
    }
    f->close();
    for (int i = 0; i < 16; i++) {
        dmaMemInfo->setItem(i, 1, new QTableWidgetItem("0000000000000000"));
    }
    dmaMemInfo->setItem(CMMD, 1, new QTableWidgetItem("00000000"));
    dmaMemInfo->setItem(MOD0, 1, new QTableWidgetItem("000000"));
    dmaMemInfo->setItem(MOD1, 1, new QTableWidgetItem("000000"));
    dmaMemInfo->setItem(MOD2, 1, new QTableWidgetItem("000000"));
    dmaMemInfo->setItem(MOD3, 1, new QTableWidgetItem("000000"));
    dmaMemInfo->setItem(MASK, 1, new QTableWidgetItem("0000"));
    dmaMemInfo->setItem(TEMP, 1, new QTableWidgetItem("00000000"));
    dmaMemInfo->setItem(STAT, 1, new QTableWidgetItem("Idle State"));
    for (int i = 0; i < 32; i++) {
        regFileInfo->setItem(i, 1, new QTableWidgetItem(QString::number(i)));
    }
    updateSingleCycle(0);
}

void MainWindow::simulate(){
    simulateSingleCycle();
}

void MainWindow::fillInstMemTable(){
    QFile *f = new QFile("../biteCode/verilogRunFile.txt");
    f->open(QIODevice::Text | QIODevice::ReadOnly);
    int instNumber = 0;
    while(!f->atEnd()){
        QString instruction ;
        char line [9];
        f->readLine(line,9);f->readLine(line,9);
        instruction+= line;
        f->readLine(line,9);f->readLine(line,9);
        instruction+= line;
        f->readLine(line,9);f->readLine(line,9);
        instruction+= line;
        f->readLine(line,9);f->readLine(line,9);
        instruction+= line;
        if(instruction != "")
            instMemInfo->setItem(instNumber, 1, new QTableWidgetItem("0b"+instruction));
        instNumber++;
    }
    f->close();
}

void MainWindow::nextCLK(){
    if(CLK != max_CLK){
        CLK ++;
        updateSingleCycle(1);
    }
}

void MainWindow::prevCLK(){
    if(CLK != 0){
        CLK--;
        updateSingleCycle(-1);
    }
}

int MainWindow::getDmaRegIndex(QString t){
    if(!t.compare("CAR0")) return CAR0;
    else if(!t.compare("CAR1")) return CAR1;
    else if(!t.compare("CAR2")) return CAR2;
    else if(!t.compare("CAR3")) return CAR3;
    else if(!t.compare("CCR0")) return CCR0;
    else if(!t.compare("CCR1")) return CCR1;
    else if(!t.compare("CCR2")) return CCR2;
    else if(!t.compare("CCR3")) return CCR3;
    else if(!t.compare("COMMAND")) return CMMD;
    else if(!t.compare("MODE0")) return MOD0;
    else if(!t.compare("MODE1")) return MOD1;
    else if(!t.compare("MODE2")) return MOD2;
    else if(!t.compare("MODE3")) return MOD3;
    else if(!t.compare("TEMP")) return TEMP;
    else if(!t.compare("MASK")) return MASK;
    else if(!t.compare("STATE")) return STAT;
}

void MainWindow::updateSingleCycle(int action){
    setLCDNumber(clkCounter,QString::number(CLK));
    if(action >= 0){
        if(regValues_CLK_Forward->contains(CLK)){
            qDebug() << "Yeahhhhh i am here" << CLK;

            QString *v =regValues_CLK_Forward->value(CLK);
            if(CLK == 3){
                qDebug() << v[0] << v[1] << v[2];
            }
            setLCDNumber(pcCounter,v[0]);
            QString *lastValue = new QString[3];
            lastValue[0] = lastPC;
            lastValue[1] = regValues_CLK_Forward->value(CLK)[1];
            lastValue[2] = regFileInfo->item(v[1].toInt(),2)->text();
            regValues_CLK_Backword->insert(CLK-1,lastValue);
            regFileInfo->setItem(v[1].toInt(), 2, new QTableWidgetItem(v[2]));
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }
        if(memValues_CLK_Forward->contains(CLK)){
            QString *v =memValues_CLK_Forward->value(CLK);
            setLCDNumber(pcCounter,v[0]);
            QString *lastValue = new QString[3];
            lastValue[0] = lastPC;
            lastValue[1] = memValues_CLK_Forward->value(CLK)[1];
            lastValue[2] = dataMemInfo->item(v[1].toInt(),1)->text();
            memValues_CLK_Backword->insert(CLK-1,lastValue);
            dataMemInfo->setItem(v[1].toInt()/4, 1, new QTableWidgetItem(v[2]));
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }
        if(dmaValues_CLK_Forward->contains(CLK)){
            for(QString *v : *dmaValues_CLK_Forward->value(CLK)){
                QString *lastValue = new QString[2];
                std::string addr = v[1].toStdString();
                lastValue[1] = v[1];
                if(addr.length() > 5 && !QString::fromStdString(addr.substr(0,5)).compare("UPPER")){
                    int index = getDmaRegIndex(QString::fromStdString(addr.substr(6,addr.length()-6)));
                    lastValue[0] = dmaMemInfo->item(index ,1)->text();
                    lastValue[1] = v[1];
                    QString data = v[0] + QString::fromStdString(lastValue[0].toStdString().substr(8,8));
                    dmaMemInfo->setItem(index, 1, new QTableWidgetItem(data));
                }else if(addr.length() > 5 && !QString::fromStdString(addr.substr(0,5)).compare("LOWER")){
                    int index = getDmaRegIndex(QString::fromStdString(addr.substr(6,addr.length()-6)));
                    lastValue[0] = dmaMemInfo->item(index,1)->text();
                    lastValue[1] = v[1];
                    QString data =  QString::fromStdString(lastValue[0].toStdString().substr(0,8)) + v[0];
                    dmaMemInfo->setItem(index, 1, new QTableWidgetItem(data));
                }else{
                    lastValue[0] = dmaMemInfo->item(getDmaRegIndex(v[1]),1)->text();
                    lastValue[1] = v[1];
                    dmaMemInfo->setItem(getDmaRegIndex(v[1]), 1, new QTableWidgetItem(v[0]));
                }
                if(!dmaValues_CLK_Backword->contains(CLK-1)){
                    QList <QString*> *dmaList = new QList<QString*>();
                    dmaList->append(lastValue);
                    dmaValues_CLK_Backword->insert(CLK-1,dmaList);
                }else{
                     dmaValues_CLK_Backword->value(CLK-1)->append(lastValue);
                }
//                dmaValues_CLK_Backword->insert(CLK-1,lastValue);
            }
        }
        if(ramValues_CLK_Forward->contains(CLK)){
            QString *v =ramValues_CLK_Forward->value(CLK);
            QString *lastValue = new QString[2];
            lastValue[0] = v[0];
            lastValue[1] = ramInfo->item(v[0].toInt(),1)->text();
            ramValues_CLK_Backword->insert(CLK-1,lastValue);
            ramInfo->setItem(v[0].toInt(), 1, new QTableWidgetItem(v[1]));
        }
        if(ioValues_CLK_Forward->contains(CLK)){
            QString *v =ioValues_CLK_Forward->value(CLK);
            QString *lastValue = new QString[2];
            lastValue[0] = v[0];
            lastValue[1] = ioInfo->item(v[0].toInt(),1)->text();
            ioValues_CLK_Backword->insert(CLK-1,lastValue);
            ioInfo->setItem(v[0].toInt()+2, 1, new QTableWidgetItem(v[1]));
        }
        if(output_CLK_Forward->contains(CLK)){
            QString *v =output_CLK_Forward->value(CLK);
            QTextCursor cursor = QTextCursor(outputTextMap->value(runningEditorName)->document());
            cursor.movePosition(QTextCursor::End);
            cursor.insertText(v[1]+"\n");
            QString *last = new QString[1];
            last[0] = lastPC;
            setLCDNumber(pcCounter,v[0]);
            output_CLK_Backword->insert(CLK-1,last);
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }

    }else{
        if(regValues_CLK_Backword->contains(CLK)){
            QString *v =regValues_CLK_Backword->value(CLK);
            setLCDNumber(pcCounter,v[0]);
            regFileInfo->setItem(v[1].toInt(), 2, new QTableWidgetItem(v[2]));
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }
        if(dmaValues_CLK_Backword->contains(CLK)){
            for(QString *v : *dmaValues_CLK_Backword->value(CLK)){
                std::string addr = v[1].toStdString();
                if(addr.length() > 5 && !QString::fromStdString(addr.substr(0,5)).compare("UPPER")){
                    int index = getDmaRegIndex(QString::fromStdString(addr.substr(6,addr.length()-6)));
                    dmaMemInfo->setItem(index, 1, new QTableWidgetItem(v[0]));
                }else if(addr.length() > 5 && !QString::fromStdString(addr.substr(0,5)).compare("LOWER")){
                    int index = getDmaRegIndex(QString::fromStdString(addr.substr(6,addr.length()-6)));
                    dmaMemInfo->setItem(index, 1, new QTableWidgetItem(v[0]));
                }else{
                    dmaMemInfo->setItem(getDmaRegIndex(v[1]), 1, new QTableWidgetItem(v[0]));
                }
            }
        }
        if(ramValues_CLK_Backword->contains(CLK)){
            QString *v = ramValues_CLK_Backword->value(CLK);
            ramInfo->setItem(v[0].toInt(), 1, new QTableWidgetItem(v[1]));
        }
        if(ioValues_CLK_Backword->contains(CLK)){
            QString *v = ioValues_CLK_Backword->value(CLK);
            ioInfo->setItem(v[0].toInt(), 1, new QTableWidgetItem(v[1]));
        }
        if(memValues_CLK_Backword->contains(CLK)){
            QString *v =memValues_CLK_Backword->value(CLK);
            setLCDNumber(pcCounter,v[0]);
            dataMemInfo->setItem((v[1].toInt())/4, 1, new QTableWidgetItem(v[2]));
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }
        if(output_CLK_Backword->contains(CLK)){
            QString *v =output_CLK_Backword->value(CLK);
            setLCDNumber(pcCounter,v[0]);
            QTextCursor cursor = QTextCursor(outputTextMap->value(runningEditorName)->document());
            cursor.movePosition(QTextCursor::End);
            cursor.select(QTextCursor::LineUnderCursor);
            cursor.deletePreviousChar();
            cursor.removeSelectedText();
            cursor.movePosition(QTextCursor::End);
            cursor.select(QTextCursor::LineUnderCursor);
            cursor.deletePreviousChar();
            cursor.removeSelectedText();
            outputTextMap->value(runningEditorName)->setTextCursor(cursor);
            runningEditor->setHighlighColor(QColor(Qt::cyan));
            runningEditor->highlightLine(runningEditor->getInstNumber(v[0].toInt()/4));
            lastPC = v[0];
        }
    }
}

void MainWindow::setLCDNumber(QLCDNumber *lcd, QString number){
    if(number.toInt() < 10){
        lcd->display("000"+number);
    }else if(number.toInt() < 100){
        lcd->display("00"+number);
    }else if(number.toInt() < 1000){
        lcd->display("0"+number);
    }else{
        lcd->display(number);
    }
}

void MainWindow::showSimTools(){
    spacerWidget = new QWidget(this);
    clkCounter = new QLCDNumber(4,this);
    clkCountLbl = new QLabel("CLK : ",this);
    PCCountLbl = new QLabel(" PC : ",this);
    pcCounter = new QLCDNumber(4,this);
    regValues_CLK_Forward = new QMap<int,QString*>;
    regValues_CLK_Backword = new QMap<int,QString*>;
    ramValues_CLK_Forward = new QMap<int,QString*>;
    ramValues_CLK_Backword = new QMap<int,QString*>;
    ioValues_CLK_Forward = new QMap<int,QString*>;
    ioValues_CLK_Backword = new QMap<int,QString*>;
    dmaValues_CLK_Forward = new QMap<int,QList<QString*>*>;
    dmaValues_CLK_Backword = new QMap<int,QList<QString*>*>;
    memValues_CLK_Forward = new QMap<int,QString*>;
    memValues_CLK_Backword = new QMap<int,QString*>;
    output_CLK_Forward = new QMap<int,QString*>;
    output_CLK_Backword = new QMap<int,QString*>;
    pcCounter->display("0000");
    pcCounter->setSegmentStyle(QLCDNumber::Flat);
    pcCounter->setStyleSheet("padding: 5px 5px 15px 15px;color:blue;font-size:px");
    clkTxt = new QLineEdit(this);
    t = new QTimer();

    clkTxt->setFixedWidth(80);
    clkTxt->setPlaceholderText("go to Clk ...");
    clkTxt->setValidator(new QIntValidator(1,10000,this));

    spacerWidget->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    spacerWidget->setVisible(true);
    clkCounter->display("0000");
    clkCounter->setSegmentStyle(QLCDNumber::Flat);
    clkCounter->setStyleSheet("padding: 50px 50px 15px 15px;color:red;font-size:px");


    toolBar->addWidget(spacerWidget);
    toolBar->addWidget(clkCountLbl);
    toolBar->addWidget(clkCounter);
    toolBar->addWidget(PCCountLbl);
    toolBar->addWidget(pcCounter);
    lastClkAction = toolBar->addAction(QIcon(QPixmap("/home/mgtm/Pictures/icons/finish.svg")),"Go to Last Clk");
    toolBar->addWidget(clkTxt);
    goToAction = toolBar->addAction(QIcon(QPixmap("/home/mgtm/Pictures/icons/go.svg")),"Go To");
    prevClkAction = toolBar->addAction(QIcon(QPixmap("/home/mgtm/Pictures/icons/prev.svg")),tr("Prev CLK"));
    nextClkAction = toolBar->addAction(QIcon(QPixmap("/home/mgtm/Pictures/icons/next.svg")),tr("Next CLK"));
    closeSimulationAction = toolBar->addAction(QIcon(QPixmap("/home/mgtm/Pictures/icons/cancel.svg")),"Close Simulation");

    connect(closeSimulationAction,SIGNAL(triggered()),this,SLOT(closeSimulation()));
    connect(nextClkAction,SIGNAL(triggered()),this,SLOT(nextCLK()));
    connect(prevClkAction,SIGNAL(triggered()),this,SLOT(prevCLK()));
    connect(lastClkAction,SIGNAL(triggered()),this,SLOT(goLastClk()));
    connect(goToAction,SIGNAL(triggered()),this,SLOT(goClk()));
    connect(t, SIGNAL(timeout()), this, SLOT(timerTick()));

}

void MainWindow::goClk(){
    CLK_dist = clkTxt->text().toInt();
    if(CLK_dist > max_CLK) CLK_dist = max_CLK;
    t->start(5);
}

void MainWindow::goLastClk(){
    CLK_dist = max_CLK;
    t->start(50);
}

void MainWindow::timerTick(){
    if(CLK > CLK_dist){
        CLK--;
        updateSingleCycle(-1);
    }else if (CLK < CLK_dist){
        CLK++;
        updateSingleCycle(1);
    }else{
        t->stop();
    }
}

void MainWindow::zoomIn(){
    editors->value(getActiveEditor())->zoomIn(1);
    (*editorZoomValue)[getActiveEditor()] = (*editorZoomValue)[getActiveEditor()] + 1;
}

void MainWindow::zoomOut(){
    int zoom = editorZoomValue->value(getActiveEditor());
    if(zoom != 1){
        (*editorZoomValue)[getActiveEditor()] = (*editorZoomValue)[getActiveEditor()] - 1;
        editors->value(getActiveEditor())->zoomOut(1);
    }
}

void MainWindow::hideSimTools(){
    t->stop();
    delete  spacerWidget;
    delete  clkCounter;
    delete  clkCountLbl;
    delete  pcCounter;
    delete PCCountLbl;
    delete  prevClkAction;
    delete nextClkAction;
    delete closeSimulationAction;
    delete clkTxt;
    delete goToAction;
    delete lastClkAction;
}

void MainWindow::closeSimulation(){
    hideSimTools();
    runningEditor->setReadOnly(false);
    runningEditorName = "";
    CLK = 0;
    running = false;
    runningEditor->reset();
    for (int i = 0; i < 32767; i++) {
        dmaMemInfo->setItem(i, 1, new QTableWidgetItem(""));
    }
    for (int i = 0; i < 32; i++) {
        regFileInfo->setItem(i, 2, new QTableWidgetItem(""));
    }
    for (int i = 0; i < 8191; i++) {
        instMemInfo->setItem(i, 1, new QTableWidgetItem(""));
    }
    runningEditor = nullptr;
}

void MainWindow::closeOutputTab(int index){
    outputTabWidget->removeTab(index);
    outputTextMap->remove(runningEditorName);
}

void MainWindow::setGeneratedCode(QString output){
    editors->value(getActiveEditor())->appendPlainText(output);
}

MainWindow::~MainWindow(){

}

