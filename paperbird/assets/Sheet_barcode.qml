import bb.cascades 1.4
import bb 1.0
import bb.cascades.multimedia 1.2
Sheet {
    id: sheetroot
    signal request_open_or_search(string u)
    onCreationCompleted: {
        camera.open();
    }
    Page {

        titleBar: TitleBar {
            title: qsTr("Barcode Reader(beta)")
            dismissAction: ActionItem {
                onTriggered: {
                    camera.close();
                    sheetroot.close()
                }
                title: qsTr("Close")
            }
        }
        content: Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom

            }
            Camera {
                id: camera
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                attachedObjects: [
                    BarcodeDetector {
                        id: barcodeDetector
                        formats: BarcodeFormat.Any
                        camera: camera

                        onBarcodeDetected: {
                            // Content of the barcode is delivered here as 'data'
                            console.log("scanned: ");
                            console.log(data);
                            scanned_text.setText(data)
                            request_open_or_search(data)
                            camera.close();
                            sheetroot.close();
                        }
                    }
                ]
                onCameraOpenFailed: {
                    console.log("camera open failed");
                    console.log(error);
                }
                onCameraOpened: {
                    camera.startViewfinder();
                    scanned_text.hintText = qsTr("Scanning...")
                    console.log("camera opened.");
                }

                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1.0
                }
            }
            Container {
                layoutProperties: StackLayoutProperties {

                }
                TextArea {
                    editable: true
                    id: scanned_text
                    textFormat: TextFormat.Plain
                    textStyle.textAlign: TextAlign.Center
                    backgroundVisible: false
                    hintText: " "

                }
            }
        }

    }

}