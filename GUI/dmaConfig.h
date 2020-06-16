#ifndef DMACONFIG_H
#define DMACONFIG_H

#include <QWidget>
#include <QLineEdit>
#include <QPushButton>
#include <QSplitter>
#include <QFormLayout>
#include <QDialog>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QTableWidget>
#include <QRadioButton>
#include <QLabel>
#include <QFrame>
#include <QCheckBox>
#include <QDebug>

class DmaConfig : public QDialog{
    Q_OBJECT
public:
    DmaConfig();
private:
    QPushButton *generateCodeBtn;
    QPushButton *configureBtn;
    QSplitter *manualConfigSplitter;
    QSplitter *ioConfigSplitter;
    QSplitter *vSplitter ;
    QFormLayout *formLayoutLeft;
    QFormLayout *formLayoutRight;
    QVBoxLayout *vLayout;
    QHBoxLayout *hLayout;
    QLineEdit *lineEdits;
    QWidget *leftW;
    QWidget *rightW;
    QWidget *buttonBox;
    QTabWidget *modesTabWidget;

    QRadioButton *ioSingleMode;
    QRadioButton *ioBlockMode;
    QRadioButton *ioDemandMode;
    QGridLayout *ioGridLayout;
    QWidget *ioWidget;
    QLabel *ioSingleIOlbl;
    QLabel *ioSingleMEMlbl;
    QLineEdit *ioSingleIOtxt;
    QLineEdit *ioSingleMEMtxt;
    QFrame *ioLine1;
    QFrame *ioLine2;
    QFrame *ioLine3;
    QLabel *ioBlockMEMfromlbl;
    QLabel *ioBlockWordCountlbl;
    QLabel *ioBlockIOlbl;
    QLineEdit *ioBlockMEMfromtxt;
    QLineEdit *ioBlockWordCounttxt;
    QLineEdit *ioBlockIOtxt;
    QLabel *ioDemandMEMlbl;
    QLabel *ioDemandIOlbl;
    QLineEdit *ioDemandMEMtxt;
    QLineEdit *ioDemandIOtxt;
    QCheckBox *ioToMem;
    QCheckBox *memAutoInit;
    QRadioButton *memSingleMode;
    QRadioButton *memBlockMode;
    QRadioButton *memDemandMode;
    QGridLayout *memGridLayout;
    QWidget *memWidget;
    QLabel *memSingleFromlbl;
    QLabel *memSingleTolbl;
    QLineEdit *memSingleFromtxt;
    QLineEdit *memSingleTotxt;
    QFrame *memLine1;
    QFrame *memLine2;
    QFrame *memLine3;
    QFrame *memLine4;
    QLabel *memBlockfromlbl;
    QLabel *memBlockWordCountlbl;
    QLabel *memBlockTolbl;
    QLineEdit *memBlockfromtxt;
    QLineEdit *memBlockWordCounttxt;
    QLineEdit *memBlockTotxt;
    QLabel *memDemandFromlbl;
    QLabel *memDemandTolbl;
    QLineEdit *memDemandFromtxt;
    QLineEdit *memDemandTotxt;
    QCheckBox *memBlockAddrDec;

    void check();
    void generateCode();

signals:
    void generated(QString code);

};

#endif // DMACONFIG_H
