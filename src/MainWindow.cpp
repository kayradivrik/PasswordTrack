#include "MainWindow.h"
#include "PasswordGen.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QHeaderView>
#include <QClipboard>
#include <QGuiApplication>
#include <QDialog>
#include <QFormLayout>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    setupUI();
    setWindowTitle("Secure Vault");
    resize(800, 600);

    if (vault.isSetupRequired()) {
        stackedWidget->setCurrentIndex(0); // Setup Page
    } else {
        stackedWidget->setCurrentIndex(1); // Unlock Page
    }
}

MainWindow::~MainWindow() {}

void MainWindow::setupUI() {
    stackedWidget = new QStackedWidget(this);
    stackedWidget->addWidget(createSetupPage());
    stackedWidget->addWidget(createUnlockPage());
    stackedWidget->addWidget(createDashboardPage());
    setCentralWidget(stackedWidget);
}

QWidget* MainWindow::createSetupPage() {
    QWidget* page = new QWidget();
    QVBoxLayout* layout = new QVBoxLayout(page);
    layout->setContentsMargins(100, 50, 100, 50);
    layout->setSpacing(15);
    
    QLabel* title = new QLabel("🛡️ Secure Vault", page);
    title->setObjectName("TitleLabel");
    title->setAlignment(Qt::AlignCenter);
    
    QLabel* lbl = new QLabel("Hoş geldin! Başlamak için ana parolanı oluştur:", page);
    lbl->setObjectName("SubtitleLabel");
    lbl->setAlignment(Qt::AlignCenter);
    
    QLineEdit* pwdEdit = new QLineEdit(page);
    pwdEdit->setEchoMode(QLineEdit::Password);
    pwdEdit->setPlaceholderText("Güçlü bir ana parola belirle...");
    
    QPushButton* btn = new QPushButton("Vault'u Kur", page);
    
    layout->addStretch();
    layout->addWidget(title);
    layout->addWidget(lbl);
    layout->addWidget(pwdEdit);
    layout->addWidget(btn);
    layout->addStretch();
    
    connect(btn, &QPushButton::clicked, [this, pwdEdit]() {
        if(vault.setupVault(pwdEdit->text())) {
            stackedWidget->setCurrentIndex(2); // Go to Dashboard
            loadData();
        } else {
            QMessageBox::critical(this, "Error", "Failed to setup database.");
        }
    });
    return page;
}

QWidget* MainWindow::createUnlockPage() {
    QWidget* page = new QWidget();
    QVBoxLayout* layout = new QVBoxLayout(page);
    layout->setContentsMargins(100, 50, 100, 50);
    layout->setSpacing(15);
    
    QLabel* title = new QLabel("🔒 Kasa Kilitli", page);
    title->setObjectName("TitleLabel");
    title->setAlignment(Qt::AlignCenter);
    
    QLabel* lbl = new QLabel("Kiliti açmak için ana parolanı gir:", page);
    lbl->setObjectName("SubtitleLabel");
    lbl->setAlignment(Qt::AlignCenter);
    
    QLineEdit* pwdEdit = new QLineEdit(page);
    pwdEdit->setEchoMode(QLineEdit::Password);
    pwdEdit->setPlaceholderText("Ana parolanızı girin...");
    
    QPushButton* btn = new QPushButton("Kilidi Aç", page);
    
    layout->addStretch();
    layout->addWidget(title);
    layout->addWidget(lbl);
    layout->addWidget(pwdEdit);
    layout->addWidget(btn);
    layout->addStretch();
    
    connect(btn, &QPushButton::clicked, [this, pwdEdit]() {
        if(vault.unlockVault(pwdEdit->text())) {
            pwdEdit->clear();
            stackedWidget->setCurrentIndex(2);
            loadData();
        } else {
            QMessageBox::warning(this, "Error", "Invalid Master Password.");
        }
    });
    return page;
}

QWidget* MainWindow::createDashboardPage() {
    QWidget* page = new QWidget();
    QVBoxLayout* layout = new QVBoxLayout(page);
    layout->setContentsMargins(30, 30, 30, 30);
    layout->setSpacing(20);
    
    QHBoxLayout* topBar = new QHBoxLayout();
    QLabel* dashTitle = new QLabel("🗝️ Parolalarım", page);
    dashTitle->setObjectName("TitleLabel");
    dashTitle->setStyleSheet("font-size: 24px; margin-bottom: 0px;");
    
    QLineEdit* searchBar = new QLineEdit(page);
    searchBar->setPlaceholderText("Ara...");
    searchBar->setFixedWidth(250);
    
    QPushButton* addBtn = new QPushButton("➕ Yeni Şifre Ekle", page);
    
    topBar->addWidget(dashTitle);
    topBar->addStretch();
    topBar->addWidget(searchBar);
    topBar->addWidget(addBtn);
    
    tableWidget = new QTableWidget(0, 4, page);
    tableWidget->setHorizontalHeaderLabels({"Servis / Site", "Kullanıcı Adı", "Parola", "İşlemler"});
    tableWidget->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    tableWidget->verticalHeader()->setVisible(false);
    tableWidget->setSelectionBehavior(QAbstractItemView::SelectRows);
    tableWidget->setEditTriggers(QAbstractItemView::NoEditTriggers);
    tableWidget->setShowGrid(false);
    
    layout->addLayout(topBar);
    layout->addWidget(tableWidget);
    
    connect(addBtn, &QPushButton::clicked, this, &MainWindow::onAddPassword);
    return page;
}

void MainWindow::loadData() {
    tableWidget->setRowCount(0);
    QList<PasswordEntry> entries = vault.getAllEntries();
    
    for (const auto& entry : entries) {
        int row = tableWidget->rowCount();
        tableWidget->insertRow(row);
        tableWidget->setItem(row, 0, new QTableWidgetItem(entry.service));
        tableWidget->setItem(row, 1, new QTableWidgetItem(entry.username));
        tableWidget->setItem(row, 2, new QTableWidgetItem("********")); // Masked in view
        
        QWidget* actionWidget = new QWidget();
        QHBoxLayout* hLayout = new QHBoxLayout(actionWidget);
        hLayout->setContentsMargins(5, 5, 5, 5);
        hLayout->setSpacing(10);
        
        QPushButton* copyBtn = new QPushButton("Kopyala");
        copyBtn->setObjectName("ActionBtn");
        
        QPushButton* delBtn = new QPushButton("Sil");
        delBtn->setObjectName("DangerBtn");
        
        hLayout->addWidget(copyBtn);
        hLayout->addWidget(delBtn);
        
        tableWidget->setCellWidget(row, 3, actionWidget);
        
        connect(copyBtn, &QPushButton::clicked, [this, entry]() { onCopyPassword(entry.password); });
        connect(delBtn, &QPushButton::clicked, [this, entry]() { onDeleteEntry(entry.id); });
    }
}

void MainWindow::onAddPassword() {
    QDialog dialog(this);
    dialog.setWindowTitle("Yeni Şifre Ekle");
    QFormLayout form(&dialog);
    
    QLineEdit* srvEdit = new QLineEdit(&dialog);
    srvEdit->setPlaceholderText("Örn: Google, GitHub");
    
    QLineEdit* usrEdit = new QLineEdit(&dialog);
    usrEdit->setPlaceholderText("kullanici_adi veya email");
    
    QLineEdit* pwdEdit = new QLineEdit(&dialog);
    pwdEdit->setPlaceholderText("Parola...");
    
    QPushButton* genBtn = new QPushButton("🎲 Üret", &dialog);
    genBtn->setObjectName("ActionBtn");
    
    QPushButton* saveBtn = new QPushButton("Kaydet", &dialog);
    
    form.addRow("Service:", srvEdit);
    form.addRow("Username:", usrEdit);
    form.addRow(genBtn, pwdEdit);
    form.addRow(saveBtn);
    
    connect(genBtn, &QPushButton::clicked, [&]() { pwdEdit->setText(PasswordGen::generate(16)); });
    connect(saveBtn, &QPushButton::clicked, [&]() {
        if(vault.addEntry(srvEdit->text(), usrEdit->text(), pwdEdit->text())) {
            loadData();
            dialog.accept();
        }
    });
    
    dialog.exec();
}

void MainWindow::onDeleteEntry(int id) {
    if(vault.deleteEntry(id)) {
        loadData();
    }
}

void MainWindow::onCopyPassword(const QString& pwd) {
    QGuiApplication::clipboard()->setText(pwd);
}

void MainWindow::onSetupVault() {}
void MainWindow::onUnlockVault() {}
void MainWindow::onGeneratePassword(QLineEdit* targetEdit) {}
