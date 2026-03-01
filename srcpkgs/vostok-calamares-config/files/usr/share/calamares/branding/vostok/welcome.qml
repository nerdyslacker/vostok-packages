import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import io.calamares.ui 

Item {
    anchors.fill: parent
    
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"  // Белый фон для светлой темы
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 25
            width: Math.min(parent.width * 0.8, 650)
            
            // Логотип Vostok (JPG с белым фоном)
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 220
                Layout.preferredHeight: 220
                color: "transparent"
                
                Image {
                    anchors.centerIn: parent
                    source: "vostok-logo.jpg"
                    sourceSize.width: 200
                    sourceSize.height: 200
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
                
                // Тонкая обводка вокруг лого
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#e2e8f0"
                    border.width: 1
                    radius: 10
                }
            }
            
            // Заголовок
            Text {
                text: "Welcome to <font color='#14b8a6'><b>Vostok Linux</b></font>"
                color: "#1e293b"
                font.pixelSize: 32
                font.family: "Noto Sans"
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 10
            }
            
            // Слоган
            Text {
                text: "Fast · Clean · Simple"
                color: "#64748b"
                font.pixelSize: 16
                font.family: "Noto Sans"
                font.letterSpacing: 1.5
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            
            // Информационный блок в сетке
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Layout.topMargin: 20
                columnSpacing: 15
                rowSpacing: 15
                
                // Карточка 1: Void Linux
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#f8fafc"
                    radius: 8
                    border.color: "#e2e8f0"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 6
                            color: "#f0fdfa"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📦"
                                font.pixelSize: 18
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "Void Linux"
                                color: "#14b8a6"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                font.family: "Noto Sans"
                            }
                            
                            Text {
                                text: "Musl/glibc · XBPS"
                                color: "#64748b"
                                font.pixelSize: 11
                                font.family: "Noto Sans"
                            }
                        }
                    }
                }
                
                // Карточка 2: Runit
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#f8fafc"
                    radius: 8
                    border.color: "#e2e8f0"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 6
                            color: "#f0f9ff"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⚡"
                                font.pixelSize: 18
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "Runit"
                                color: "#0ea5e9"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                font.family: "Noto Sans"
                            }
                            
                            Text {
                                text: "Fast init system"
                                color: "#64748b"
                                font.pixelSize: 11
                                font.family: "Noto Sans"
                            }
                        }
                    }
                }
                
                // Карточка 3: KDE Plasma
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#f8fafc"
                    radius: 8
                    border.color: "#e2e8f0"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 6
                            color: "#faf5ff"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🎨"
                                font.pixelSize: 18
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "KDE Plasma"
                                color: "#8b5cf6"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                font.family: "Noto Sans"
                            }
                            
                            Text {
                                text: "Modern desktop"
                                color: "#64748b"
                                font.pixelSize: 11
                                font.family: "Noto Sans"
                            }
                        }
                    }
                }
                
                // Карточка 4: Package Manager
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#f8fafc"
                    radius: 8
                    border.color: "#e2e8f0"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 6
                            color: "#f0fdf4"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🔒"
                                font.pixelSize: 18
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "XBPS"
                                color: "#10b981"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                font.family: "Noto Sans"
                            }
                            
                            Text {
                                text: "Binary package manager"
                                color: "#64748b"
                                font.pixelSize: 11
                                font.family: "Noto Sans"
                            }
                        }
                    }
                }
            }
            
            // Предупреждение (мягкое)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "#fffbeb"
                radius: 8
                border.color: "#fef3c7"
                border.width: 1
                Layout.topMargin: 20
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: "#f59e0b"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⚠"
                            color: "white"
                            font.pixelSize: 16
                        }
                    }
                    
                    Text {
                        text: "This installer will <b>erase all data</b> on the selected disk.<br>Make sure to backup your important files!"
                        color: "#92400e"
                        font.pixelSize: 12
                        font.family: "Noto Sans"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}