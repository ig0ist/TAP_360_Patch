import QtQuick 2.0

import HmiRVC 1.0

import HmiGui 1.0
import HmiGuiFramework 1.0
import HmiGuiFramework.Controls 1.0
import HmiGuiFramework.Styles 1.0

import Hmi.Ford.Popups 1.0
import Hmi.Ford.Controls 1.0

import "components"
import AL2HMIBridge 1.0 as AL2HMIBridge

//analog camera image size: 1040x605, x: 120, y: 98

RVCBasePopup {
    id: root
    objectName: "RVCPopup"

    property Style _rVCPopupStyle: UiTheme.styleSelect("rvcPopupStyle", root)

    function isvalidSappState() {
        return (AL2HMIBridge.rvcSource.sappStatus !== AL2HMIBridge.RVCSource.NoMessage
                && AL2HMIBridge.rvcSource.sappStatus !== 0
                && AL2HMIBridge.rvcSource.sappStatus !== 0xFF
                && AL2HMIBridge.rvcSource.sappStatus !== 0xFe);
    }


    function isvalidAPASappState() {
        return (AL2HMIBridge.rvcSource.sappStatus !== AL2HMIBridge.RVCSource.NoMessage
                && AL2HMIBridge.rvcSource.sappStatus !== 0)

    }

    function isvalidAPACSISystemState() {
        return (AL2HMIBridge.rvcSource.apaSystemStatus !== AL2HMIBridge.RVCSource.APASystemStatus_Null
                && AL2HMIBridge.rvcSource.apaSystemStatus !== AL2HMIBridge.RVCSource.APASystemStatus_Off)
    }


    function parkingSwitchLeftMargin() {
        if (root.show360View )
            return (-UiTheme.styleRoot.generalMarginHuge - parkAidSwitch.width/2 ); // Updated Parking Switch function per Jira ticket 35408
        else
            return _rVCPopupStyle.parkAidSwitchLeftMargin; //if PDC image is displayed, park aid button is next to it
    }

    transparentWindow: true

    property bool apaCsiActive: AL2HMIBridge.rvcSource.driverAssistConfiguration === AL2HMIBridge.RVCSource.RearFrontPDCWithAPACSI

    property bool fapaActive: AL2HMIBridge.rvcSource.driverAssistConfiguration === AL2HMIBridge.RVCSource.RearFrontPDCWithFAPA

    property bool showParkAssist:  (_parkAssistController.parkAssistActive && isvalidAPASappState()
                                   && (AL2HMIBridge.rvcSource.activeAssistMode !== AL2HMIBridge.RVCSource.NoneActive)
                                   && (AL2HMIBridge.rvcSource.activeAssistMode !== AL2HMIBridge.RVCSource.ActiveModeOff)
                                   && !apaCsiActive && !fapaActive
                                   && !AL2HMIBridge.rvcSource.rearCameraOnDemandActive)
    property bool showSemiAutomaticParallelParking: _parkAssistController.semiAutomaticParallelParkingActive
                                                    && isvalidSappState()
                                                    && !_parkAssistController.showSAPPException
                                                    && !apaCsiActive && !fapaActive
                                                    && !AL2HMIBridge.rvcSource.rearCameraOnDemandActive
    property bool show360View: AL2HMIBridge.rvcSource.multicameraView
                               && (AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFront360
                                   || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBRear360)
    property bool showSplitView: AL2HMIBridge.rvcSource.multicameraView
                                 && (AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFrontSplit
                                     || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBRearSplit)
    property bool showAuxView: AL2HMIBridge.rvcSource.multicameraView && AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBAux

    property bool showFrontCamera: AL2HMIBridge.rvcSource.multicameraView
                                   && (AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFront360
                                       || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFrontNormal
                                       || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFrontSplit
                                       || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBFront
                                       || ((AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBAux
                                            || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBChmsl)
                                           && AL2HMIBridge.globalSource.transmissionStatus !== AL2HMIBridge.GlobalSource.TransmissionStatusReverse))
    property bool showZoomControls: !showParkAssist && !showSemiAutomaticParallelParking && !((apaCsiActive || fapaActive) && isvalidAPACSISystemState())

    property bool showCtaIcons: AL2HMIBridge.rvcSource.crossTrafficAlertEnabled && showZoomControls && !showAuxView
                                && !AL2HMIBridge.rvcSource.rearCameraOnDemandActive
                                && (AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFront360 &&
                                    AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontNormal &&
                                    AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontSplit)
    property bool cameraViewActivatedByReverseGear : AL2HMIBridge.rvcSource.cameraActivationReason === AL2HMIBridge.RVCSource.CameraActivationReasonReverseGear

    rootPopupContents: Item {
        id: container

        property bool landscapeLayout: true

        anchors.fill: parent

        CameraViewButtons {
            id:cameraViewButtons
            cameraButtonObjectName : "RVCPopup_cameraViewButtons"

            anchors {
                top: parent.top
                left: parent.left
                margins: UiTheme.styleRoot.generalMarginSmall
            }
            visible: !showParkAssist && !showSemiAutomaticParallelParking && AL2HMIBridge.rvcSource.multiCamSoftButtons
                     && !((apaCsiActive || fapaActive) && isvalidAPACSISystemState())
                     && !AL2HMIBridge.rvcSource.rearCameraOnDemandActive
            expendableMode: AL2HMIBridge.rvcSource.hasDigitalRVC
        }

        ZoomControls {
            id: zoomControlsShow360_hmirvcpopup

            zoomButtonObjectName : "RVCPopup_zoomButton"
            warnLabelObjectName	: "RVCPopup_textLabel"
            cancelButtonObjectName: "RVCPopup_cancelButton"
            nonMultiCameraButtonObjectName: "RVCPopup_nonMultiCameraButton"

            show360View: root.show360View && AL2HMIBridge.rvcSource.hasDigitalRVC
            camera360RightOffset: 560
            cameraXOffset: AL2HMIBridge.rvcSource.hasDigitalRVC ? 0 : 120
            cameraYOffset: AL2HMIBridge.rvcSource.hasDigitalRVC ? 0 : 98
            showZoomButton: !showFrontCamera
                            && !showSplitView
                            && !showAuxView
                            && (AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMax || AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMin)
                            && !ViewController.qrvc
            showPDC: !root.show360View && !root.showSplitView
                     && AL2HMIBridge.rvcSource.rvcZoomLevel !== AL2HMIBridge.RVCSource.ZoomLevelMax
            //The PDC component also works for popups with no camera underlay
            //and we need to ensure that it is not shown when there is no camera feed
            //as it would blink when the popup was hidden (SPAGETTY)
                     && AL2HMIBridge.rvcSource.parkAidSelected
            showCancelButton:(AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFront360 &&
                              AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontNormal &&
                              AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontSplit) && _hmirvcController.cancelButtonActive &&
                              AL2HMIBridge.rvcSource.rvcDelayExit && AL2HMIBridge.globalSource.transmissionStatus !== AL2HMIBridge.GlobalSource.TransmissionStatusReverse &&
                             cameraViewActivatedByReverseGear

            visible: showZoomControls &&
                     ((AL2HMIBridge.rvcSource.nonMulticameraSplitViewConfiguration && AL2HMIBridge.rvcSource.multiCamSoftButtons && AL2HMIBridge.rvcSource.nonMulticameraShowing !== AL2HMIBridge.RVCSource.NonMultiCameraInvalid) ||
                     (!AL2HMIBridge.rvcSource.multiCamSoftButtons || AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBOff) ||
                      AL2HMIBridge.rvcSource.rearCameraOnDemandActive ||
                     (!AL2HMIBridge.rvcSource.multicameraView && !AL2HMIBridge.rvcSource.nonMulticameraSplitViewConfiguration))
        }

        APACameraText{

            aPACameraBottomTextObjectName : "RVCPopup_APACameraBottomText"
            aPACameraHeaderTextObjectName : "RVCPopup_APACameraHeaderText"
            aPACameraTextIconObjectName  : "RVCPopup_APACameraTextIcon"

            anchors.rightMargin: show360View ? 320 : 0
            show360View: root.show360View
            showPDC: !showSplitView && !show360View
            cameraXOffset: AL2HMIBridge.rvcSource.hasDigitalRVC ? 0 : 120
            cameraYOffset: AL2HMIBridge.rvcSource.hasDigitalRVC ? 0 : 98

            visible: showParkAssist
        }

        ParkAidSwitch {
            id: parkAidSwitch
            objectName: "RVCPopup_parkAidSwitch"

            anchors {
                top: parent.top
                topMargin: 1    //Adjusted with other Camera View button due to offset value vs 10inchL framework.
                left: parent.horizontalCenter
                leftMargin: parkingSwitchLeftMargin()
            }
            showLabel: false
            cameraScreen:true

            visible: AL2HMIBridge.rvcSource.hasCameraHotkey
                     && ( AL2HMIBridge.rvcSource.rearCameraOnDemandActive
                         || (((AL2HMIBridge.globalSource.transmissionStatus === AL2HMIBridge.GlobalSource.TransmissionStatusReverse)
                              || !(AL2HMIBridge.rvcSource.boundaryAlertLeftActive
                                   || AL2HMIBridge.rvcSource.boundaryAlertRightActive
                                   || _hmirvcController.videoOnDemandIsActive))
                             && !(show360View && cameraViewButtons.buttonsVisible)))
                     && (!showParkAssist) && AL2HMIBridge.rvcSource.apaSystemStatus <= AL2HMIBridge.RVCSource.APASystemStatus_Off

            // added on clicked per Jira ticket 35408
            onToggleButtonClicked: {
                //disable Auto Dismiss because now popup has new timeout
                _parkAssistController.disableParkHotKeyPopupDismissMode();
            }
        }

        APACSICameraText {
            visible: (apaCsiActive || fapaActive) && isvalidAPACSISystemState()
                     && !AL2HMIBridge.rvcSource.rearCameraOnDemandActive
        }

        SAPPCameraText {

            sAPPCameraLeftIconObjectName:  "RVCPopup_SAPPCameraLeftIcon"
            sAPPCameraRightIconObjectName : "RVCPopup_SAPPCameraRightIcon"


            visible: showSemiAutomaticParallelParking
        }

        SAPPExceptionPanel {
            visible: _parkAssistController.showSAPPException
        }

        CrossTrafficAlertIcons {
            id: crossTrafficAlertIcons

            rightCrossTrafficAlertIconsObjectName: "RVCPopup_CrossTrafficAlertRightIcon"
            leftCrossTrafficAlertIconsObjectName : "RVCPopup_CrossTrafficAlertLeftIcon"

            visible: showCtaIcons
            anchors.rightMargin: (root.show360View && AL2HMIBridge.rvcSource.hasDigitalRVC)? 560 : 0
        }

        HmiImage {
            anchors.centerIn : parent
            anchors.verticalCenterOffset: -parent.height / 4

            visible: AL2HMIBridge.rvcSource.rearCameraOnDemandActive
            source: UiTheme.palette.image("rvc/rvcod_overlay");

            RVCTextLabel {
                anchors.fill: parent

                text: AL2HMIBridge.globalSource.transmissionStatus === AL2HMIBridge.GlobalSource.TransmissionStatusParking
                        //~ TextID 19f54148-06b8-11e8-b98a-0800270422e6
                        ? qsTr("Vehicle in Park")
                        //~ TextID 19f54cb0-06b8-11e8-b98a-0800270422e6
                        : qsTr("Please check surroundings for safety")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                variation: _rVCPopupStyle.warningLabelVariation
            }
        }
    }
}
