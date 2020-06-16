#include "dmaConfig.h"

DmaConfig::DmaConfig(){
    generateCodeBtn= new QPushButton("Generate Assembly Code");
    configureBtn= new QPushButton("Configure DMA");
    lineEdits =new QLineEdit[16];
    manualConfigSplitter=new QSplitter(Qt::Horizontal);
    formLayoutLeft = new QFormLayout();
    formLayoutRight = new QFormLayout();
    leftW = new QWidget();
    rightW = new QWidget();
    vLayout = new QVBoxLayout();
    hLayout = new QHBoxLayout();
    buttonBox = new QWidget();
    modesTabWidget = new QTabWidget();
    ioConfigSplitter = new QSplitter(Qt::Vertical);
    ioSingleMode = new QRadioButton("Single Mode");
    ioBlockMode = new QRadioButton("Block Mode");
    ioDemandMode = new QRadioButton("Demand Mode");
    ioGridLayout = new QGridLayout();
    ioWidget = new QWidget();
    ioLine1 = new QFrame();
    ioLine2 = new QFrame();
    ioLine3 = new QFrame();
    ioSingleIOlbl = new QLabel("I/O Address : ");
    ioSingleMEMlbl = new QLabel("MEM Address : ");
    ioSingleIOtxt = new QLineEdit();
    ioSingleMEMtxt = new QLineEdit();
    ioBlockMEMfromlbl = new QLabel("From MEM Address : ");
    ioBlockWordCountlbl = new QLabel("Word Count : ");
    ioBlockIOlbl = new QLabel("I/O Address : ");
    ioBlockMEMfromtxt = new QLineEdit();
    ioBlockWordCounttxt = new QLineEdit();
    ioBlockIOtxt = new QLineEdit();
    ioDemandMEMlbl = new QLabel("MEM Address : ");
    ioDemandIOlbl = new QLabel("I/O Address : ");
    ioDemandMEMtxt = new QLineEdit();
    ioDemandIOtxt = new QLineEdit();
    ioToMem = new QCheckBox("I/O to MEM");
    memGridLayout = new QGridLayout();
    memWidget = new QWidget();
    memSingleFromlbl = new QLabel("Src Address : ");
    memSingleTolbl = new QLabel("Dist Address");
    memSingleFromtxt = new QLineEdit();
    memSingleTotxt = new QLineEdit();
    memLine1 = new QFrame();
    memLine2 = new QFrame();
    memLine3 = new QFrame();
    memLine4 = new QFrame();
    memBlockfromlbl = new QLabel("Src Address : ");
    memBlockWordCountlbl = new QLabel("Word Count : ");
    memBlockTolbl = new QLabel("Dist Address : ");
    memBlockfromtxt = new QLineEdit();
    memBlockWordCounttxt = new QLineEdit();
    memBlockTotxt = new QLineEdit();
    memDemandFromlbl = new QLabel("Src Address : ");
    memDemandTolbl = new QLabel("To Address : ");
    memDemandFromtxt = new QLineEdit();
    memDemandTotxt = new QLineEdit();
    memSingleMode = new QRadioButton("Single Mode");
    memBlockMode = new QRadioButton("Block Mode");
    memDemandMode = new QRadioButton("Demand Mode");
    memAutoInit = new QCheckBox("Auto Init");
    memBlockAddrDec = new QCheckBox("Address Decrement");

    ioLine1->setFrameShape(QFrame::HLine);
    ioLine1->setFrameShadow(QFrame::Sunken);
    ioLine2->setFrameShape(QFrame::HLine);
    ioLine2->setFrameShadow(QFrame::Sunken);
    ioLine3->setFrameShape(QFrame::HLine);
    ioLine3->setFrameShadow(QFrame::Sunken);

    memLine1->setFrameShape(QFrame::HLine);
    memLine1->setFrameShadow(QFrame::Sunken);
    memLine2->setFrameShape(QFrame::HLine);
    memLine2->setFrameShadow(QFrame::Sunken);
    memLine3->setFrameShape(QFrame::HLine);
    memLine3->setFrameShadow(QFrame::Sunken);
    memLine4->setFrameShape(QFrame::HLine);
    memLine4->setFrameShadow(QFrame::Sunken);

    this->setLayout(vLayout);
    vLayout->addWidget(modesTabWidget);
    modesTabWidget->addTab(ioWidget,"I/O to Memory");
    modesTabWidget->addTab(memWidget,"Memory to Memory");
    modesTabWidget->addTab(manualConfigSplitter,"Manual Registers");

    // Manual Config
    manualConfigSplitter->addWidget(leftW);
    manualConfigSplitter->addWidget(rightW);
    leftW->setLayout(formLayoutLeft);
    rightW->setLayout(formLayoutRight);
    formLayoutLeft->addRow("Reg1 : ",&lineEdits[0]);
    formLayoutLeft->addRow("Reg2 : ",&lineEdits[1]);
    formLayoutLeft->addRow("Reg3 : ",&lineEdits[2]);
    formLayoutLeft->addRow("Reg4 : ",&lineEdits[3]);
    formLayoutLeft->addRow("Reg5 : ",&lineEdits[4]);
    formLayoutLeft->addRow("Reg6 : ",&lineEdits[5]);
    formLayoutLeft->addRow("Reg7 : ",&lineEdits[6]);
    formLayoutLeft->addRow("Reg8 : ",&lineEdits[7]);
    formLayoutRight->addRow("Reg9 : ",&lineEdits[8]);
    formLayoutRight->addRow("Reg10 : ",&lineEdits[9]);
    formLayoutRight->addRow("Reg11 : ",&lineEdits[10]);
    formLayoutRight->addRow("Reg12 : ",&lineEdits[11]);
    formLayoutRight->addRow("Reg13 : ",&lineEdits[12]);
    formLayoutRight->addRow("Reg14 : ",&lineEdits[13]);
    formLayoutRight->addRow("Reg15 : ",&lineEdits[14]);
    formLayoutRight->addRow("Reg16 : ",&lineEdits[15]);
    formLayoutRight->setSpacing(15);
    formLayoutLeft->setSpacing(15);

    // io Config
    ioWidget->setLayout(ioGridLayout);
    ioGridLayout->setAlignment(Qt::AlignTop);
    ioGridLayout->addWidget(ioSingleMode,0,0);
    ioGridLayout->setRowMinimumHeight(1,5);
    ioGridLayout->addWidget(ioSingleMEMlbl,2,0);
    ioGridLayout->addWidget(ioSingleMEMtxt,2,1);
    ioGridLayout->addWidget(ioSingleIOlbl,2,2);
    ioGridLayout->addWidget(ioSingleIOtxt,2,3);
    ioGridLayout->setRowMinimumHeight(3,5);
    ioGridLayout->addWidget(ioLine1,4,0,1,4);
    ioGridLayout->setRowMinimumHeight(5,5);
    ioGridLayout->addWidget(ioBlockMode,6,0);
    ioGridLayout->setRowMinimumHeight(7,5);
    ioGridLayout->addWidget(ioBlockMEMfromlbl,8,0);
    ioGridLayout->addWidget(ioBlockMEMfromtxt,8,1);
    ioGridLayout->addWidget(ioBlockWordCountlbl,8,2);
    ioGridLayout->addWidget(ioBlockWordCounttxt,8,3);
    ioGridLayout->addWidget(ioBlockIOlbl,9,0);
    ioGridLayout->addWidget(ioBlockIOtxt,9,1);
    ioGridLayout->setRowMinimumHeight(10,5);
    ioGridLayout->addWidget(ioLine2,11,0,1,4);
    ioGridLayout->setRowMinimumHeight(12,5);
    ioGridLayout->addWidget(ioDemandMode,13,0);
    ioGridLayout->setRowMinimumHeight(14,5);
    ioGridLayout->addWidget(ioDemandMEMlbl,15,0);
    ioGridLayout->addWidget(ioDemandMEMtxt,15,1);
    ioGridLayout->addWidget(ioDemandIOlbl,15,2);
    ioGridLayout->addWidget(ioDemandIOtxt,15,3);
    ioGridLayout->setRowMinimumHeight(16,5);
    ioGridLayout->addWidget(ioLine3,18,0,1,4);
    ioGridLayout->addWidget(ioToMem,19,3,Qt::AlignRight);

    //mem to mem config
    memWidget->setLayout(memGridLayout);
    memGridLayout->setAlignment(Qt::AlignTop);
    memGridLayout->addWidget(memSingleMode,0,0);
    memGridLayout->setRowMinimumHeight(1,5);
    memGridLayout->addWidget(memSingleFromlbl,2,0);
    memGridLayout->addWidget(memSingleFromtxt,2,1);
    memGridLayout->addWidget(memSingleTolbl,2,2);
    memGridLayout->addWidget(memSingleTotxt,2,3);
    memGridLayout->setRowMinimumHeight(3,5);
    memGridLayout->addWidget(memLine1,4,0,1,4);
    memGridLayout->setRowMinimumHeight(5,5);
    memGridLayout->addWidget(memBlockMode,6,0);
    memGridLayout->setRowMinimumHeight(7,5);
    memGridLayout->addWidget(memBlockfromlbl,8,0);
    memGridLayout->addWidget(memBlockfromtxt,8,1);
    memGridLayout->addWidget(memBlockWordCountlbl,8,2);
    memGridLayout->addWidget(memBlockWordCounttxt,8,3);
    memGridLayout->addWidget(memBlockTolbl,9,0);
    memGridLayout->addWidget(memBlockTotxt,9,1);
    memGridLayout->addWidget(memBlockAddrDec,9,3);
    memGridLayout->setRowMinimumHeight(10,5);
    memGridLayout->addWidget(memLine2,11,0,1,4);
    memGridLayout->setRowMinimumHeight(12,5);
    memGridLayout->addWidget(memDemandMode,13,0);
    memGridLayout->setRowMinimumHeight(14,5);
    memGridLayout->addWidget(memDemandFromlbl,15,0);
    memGridLayout->addWidget(memDemandFromtxt,15,1);
    memGridLayout->addWidget(memDemandTolbl,15,2);
    memGridLayout->addWidget(memDemandTotxt,15,3);
    memGridLayout->setRowMinimumHeight(16,5);
    memGridLayout->addWidget(memLine4,17,0,1,4);
    memGridLayout->addWidget(memAutoInit,18,3,Qt::AlignRight);


    vLayout->addWidget(buttonBox);
    buttonBox->setLayout(hLayout);
    hLayout->addWidget(generateCodeBtn);
    hLayout->addWidget(configureBtn);

    setWindowFlags(Qt::Drawer);

    ioSingleMode->setChecked(true);
    memSingleMode->setChecked(true);

    check();

    connect(ioSingleMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(ioBlockMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(ioDemandMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(memSingleMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(memBlockMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(memDemandMode, &QRadioButton::toggled,this,&DmaConfig::check);
    connect(generateCodeBtn, &QPushButton::clicked, this, &DmaConfig::generateCode);

    this->setWindowTitle("DMA Configrations");
}

void DmaConfig::check(){
    if(ioSingleMode->isChecked()){
        ioSingleIOtxt->setEnabled(true);
        ioSingleMEMtxt->setEnabled(true);
        ioBlockIOtxt->setEnabled(false);
        ioBlockMEMfromtxt->setEnabled(false);
        ioBlockWordCounttxt->setEnabled(false);
        ioDemandIOtxt->setEnabled(false);
        ioDemandMEMtxt->setEnabled(false);
    }else if(ioBlockMode->isChecked()){
        ioSingleIOtxt->setEnabled(false);
        ioSingleMEMtxt->setEnabled(false);
        ioBlockIOtxt->setEnabled(true);
        ioBlockMEMfromtxt->setEnabled(true);
        ioBlockWordCounttxt->setEnabled(true);
        ioDemandIOtxt->setEnabled(false);
        ioDemandMEMtxt->setEnabled(false);
    }else{
        ioSingleIOtxt->setEnabled(false);
        ioSingleMEMtxt->setEnabled(false);
        ioBlockIOtxt->setEnabled(false);
        ioBlockMEMfromtxt->setEnabled(false);
        ioBlockWordCounttxt->setEnabled(false);
        ioDemandIOtxt->setEnabled(true);
        ioDemandMEMtxt->setEnabled(true);
    }

    if(memSingleMode->isChecked()){
        memSingleTotxt->setEnabled(true);
        memSingleFromtxt->setEnabled(true);
        memBlockTotxt->setEnabled(false);
        memBlockfromtxt->setEnabled(false);
        memBlockWordCounttxt->setEnabled(false);
        memDemandTotxt->setEnabled(false);
        memDemandFromtxt->setEnabled(false);
    }else if(memBlockMode->isChecked()){
        memSingleTotxt->setEnabled(false);
        memSingleFromtxt->setEnabled(false);
        memBlockTotxt->setEnabled(true);
        memBlockfromtxt->setEnabled(true);
        memBlockWordCounttxt->setEnabled(true);
        memDemandTotxt->setEnabled(false);
        memDemandFromtxt->setEnabled(false);
    }else{
        memSingleTotxt->setEnabled(false);
        memSingleFromtxt->setEnabled(false);
        memBlockTotxt->setEnabled(false);
        memBlockfromtxt->setEnabled(false);
        memBlockWordCounttxt->setEnabled(false);
        memDemandTotxt->setEnabled(true);
        memDemandFromtxt->setEnabled(true);
    }
}

void DmaConfig::generateCode(){
    if(!modesTabWidget->tabText(modesTabWidget->currentIndex()).compare("Memory to Memory")){
        if(memSingleMode->isChecked()){
            qDebug() << "single";
            QString srcAddr = memSingleFromtxt->text();
            QString distSrc = memSingleTotxt->text();
            QString output = "";
            output += "rst\n";
            output += "rstb\n";
            output += "strtdma\n";
            if(!memAutoInit->isChecked()){
                output += "lbus $MODE0, 80\n";
            }else{
                output += "lbus $MODE0, 64\n";
            }
            output += "lbus $MODE0, 81\n";
            output += "lbus $CAR0, " + srcAddr + "\n";
            output += "lbus $CAR0, 0\n";
            output += "lbus $CAR1, " + distSrc + "\n";
            output += "lbus $CAR1, 0\n";
            output += "lbus $COMMAND, 1\n";
            output += "endma\n";
            output += "dreq 1\n";
            emit generated(output);
        }else if(memBlockMode->isChecked()){
            qDebug() << "block";
            QString srcAddr = memBlockfromtxt->text();
            QString wordCount = memBlockWordCounttxt->text();
            QString distSrc = memBlockTotxt->text();
            qDebug() << srcAddr << wordCount << distSrc;
            QString output = "";
            output += "rst\n";
            output += "rstb\n";
            output += "strtdma\n";
            if(!memAutoInit->isChecked() && memBlockAddrDec->isChecked()){
                output += "lbus $MODE0, 176\n";
                output += "lbus $MODE0, 177\n";
            }else if(!memAutoInit->isChecked() && !memBlockAddrDec->isChecked()){
                output += "lbus $MODE0, 144\n";
                output += "lbus $MODE0, 145\n";
            }else if(memAutoInit->isChecked() && memBlockAddrDec->isChecked()){
                output += "lbus $MODE0, 160\n";
                output += "lbus $MODE0, 177\n";
            }else if(memAutoInit->isChecked() && !memBlockAddrDec->isChecked()){
                output += "lbus $MODE0, 128\n";
                output += "lbus $MODE0, 145\n";
            }
            output += "lbus $CAR0, " + srcAddr + "\n";
            output += "lbus $CAR0, 0\n";
            output += "lbus $CAR1, " + distSrc + "\n";
            output += "lbus $CAR1, 0\n";
            output += "lbus $CCR1, " + wordCount + "\n";
            output += "lbus $CCR1, 0\n";
            output += "lbus $COMMAND, 1\n";
            output += "endma\n";
            output += "dreq 1\n";
            emit generated(output);
            qDebug() << output;
        }else if(memDemandMode->isChecked()){
            qDebug() << "demand";
        }
    }
//    this->close();

}
