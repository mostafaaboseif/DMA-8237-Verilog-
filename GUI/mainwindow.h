#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QToolBar>
#include <QMenuBar>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QDesktopWidget>
#include <QFileDialog>
#include <QInputDialog>
#include <QProcess>
#include <string>
#include <QShortcut>
#include <QSplitter>
#include <QMap>
#include <QTableWidget>
#include <QVector>
#include <QLCDNumber>
#include <QLabel>
#include <QActionGroup>
#include <QTimer>
#include <QGraphicsPixmapItem>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QStatusBar>
#include "editor.h"
#include "highlighter.h"
#include "directoryviewer.h"
#include "dmaConfig.h"

#define CAR0 0
#define CAR1 1
#define CAR2 2
#define CAR3 3
#define CCR0 4
#define CCR1 5
#define CCR2 6
#define CCR3 7
#define CMMD 8
#define MOD0 9
#define MOD1 10
#define MOD2 11
#define MOD3 12
#define MASK 13
#define TEMP 14
#define STAT 15

class MainWindow : public QMainWindow{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();


private slots:
    void openFile();
    void newFile();
    void saveFile();
    void compileFile();
    void dmaConfigShow();
    void runFile();
    void closeTab(int);
    void dViewerDoubleClick(QModelIndex);
    void zoomIn();
    void zoomOut();
    void nextCLK();
    void prevCLK();
    void closeSimulation();
    void timerTick();
    void goLastClk();
    void goClk();
    void closeOutputTab(int);


private:
    QSplitter *vSplitter;
    QSplitter *hSplitter;
    QSplitter *subhSplitter;
    DmaConfig *dmaConfig;
    QMenu *file;
    QAction *quit;
    QAction *singleCycleMipsAction;
    QToolBar *toolBar ;
    QTabWidget *tabWidget;
    QTabWidget *simulationTabWidget;
    QTabWidget *outputTabWidget;
    QWidget *spacerWidget;
    QStatusBar *status;
    QMap<QString, QPlainTextEdit*> *outputTextMap;
    QMap<QString,Editor*> *editors;
    QMap<QString,QFile*> *files;
    QMap<QString,QString> *paths;
    QMap<int,QString*> *regValues_CLK_Forward;
    QMap<int,QString*> *regValues_CLK_Backword;
    QMap<int,QList<QString*>*> *dmaValues_CLK_Forward;
    QMap<int,QList<QString*>*> *dmaValues_CLK_Backword;
    QMap<int,QString*> *ramValues_CLK_Forward;
    QMap<int,QString*> *ramValues_CLK_Backword;
    QMap<int,QString*> *ioValues_CLK_Forward;
    QMap<int,QString*> *ioValues_CLK_Backword;
    QMap<int,QString*> *output_CLK_Forward;
    QMap<int,QString*> *output_CLK_Backword;
    QMap<QString,int> *editorZoomValue;
    QMap<int,QString*> *memValues_CLK_Forward;
    QMap<int,QString*> *memValues_CLK_Backword;
    QAction *newAction;
    QAction *openAction;
    QAction *saveAction;
    QAction *compileAction;
    QAction *runAction;
    QAction *dmaConfigAction;
    QAction *nextClkAction;
    QAction *prevClkAction;
    QAction *closeSimulationAction;
    QAction *goToAction;
    QAction *lastClkAction;
    QActionGroup *mipsType;
    QLineEdit *clkTxt;
    QTimer *t;
    QShortcut *saveShortcut;
    QShortcut *openShortcut;
    QShortcut *compileShortcut;
    QShortcut *runShortcut;
    QShortcut *zoomInShortcut;
    QShortcut *zoomOutShortcut;
    QLabel *clkCountLbl;
    QLabel *PCCountLbl;
    QLabel *PCCountLbl_IF;
    QLabel *PCCountLbl_ID;
    QLabel *PCCountLbl_EX;
    QLabel *PCCountLbl_MEM;
    QLabel *PCCountLbl_WB;
    QProcess *assemblerProcess;
    QProcess *runProcess;
    QTableWidget *regFileInfo;
    QTableWidget *dmaMemInfo;
    QTableWidget *ioInfo;
    QTableWidget *ioInfo2;
    QTableWidget *ioInfo3;
    QTableWidget *instMemInfo;
    QTableWidget *dataMemInfo;
    QTableWidget *ramInfo;
    DirectoryViewer *dViewer;
    QLCDNumber *clkCounter;
    QLCDNumber *pcCounter;
    QLCDNumber *pcCounter_IF;
    QLCDNumber *pcCounter_ID;
    QLCDNumber *pcCounter_EX;
    QLCDNumber *pcCounter_MEM;
    QLCDNumber *pcCounter_WB;
    Editor *runningEditor;
    int CLK = 0;
    int max_CLK = 0;
    int CLK_dist = 0;
    QString lastPC = 0;
    QString lastMemWrite = 0;
    QString runningEditorName;
    void initToolBar();
    void initMenus();
    void initRegfileTable();
    void initDmaMemTable();
    void initInstMemTable();
    void initRamTable();
    void initIOTable();
    void initIOTable2();
    void initIOTable3();
    void initDataMemTable();
    void fillInstMemTable();
    void simulate();
    void showSimTools();
    void hideSimTools();
    void setLCDNumber(QLCDNumber*, QString);
    QString getActiveEditor();
    void updateSingleCycle(int);
    void simulateSingleCycle();
    int getDmaRegIndex(QString);
    bool running = false;
    QString regNames [32] = {"$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3", "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6",
                             "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra"};
    QString dmaRegs [17] = {"CAR0", "CAR1", "CAR2", "CAR3", "CCR0", "CCR1", "CCR2", "CCR3", "COMMAND",
                            "MODE0", "MODE1", "MODE2", "MODE3", "MASK", "TEMP", "State"};
    void setGeneratedCode(QString output);
};

#endif // MAINWINDOW_H
