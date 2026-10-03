#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QStackedWidget>
#include <QTableWidget>
#include <QLineEdit>
#include <QPushButton>
#include "VaultManager.h"

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    VaultManager vault;
    QStackedWidget *stackedWidget;
    QTableWidget *tableWidget;
    
    // UI Setup
    void setupUI();
    QWidget* createSetupPage();
    QWidget* createUnlockPage();
    QWidget* createDashboardPage();

    // Logic
    void loadData();
    
private slots:
    void onSetupVault();
    void onUnlockVault();
    void onAddPassword();
    void onGeneratePassword(QLineEdit* targetEdit);
    void onDeleteEntry(int id);
    void onCopyPassword(const QString& pwd);
};

#endif // MAINWINDOW_H
