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

RVCBasePopup {
    id: root
    objectName: "RVCPopup"

    property Style _cameraButtonStyle: UiTheme.styleSelect("cameraViewButtons", root)
    property Style _rVCPopupStyle: UiTheme.styleSelect("rvcPopupStyle", root)
    readonly property bool brakeEvent: _parkAssistController.rbaController.alertState
    readonly property bool showVideoOnDemand: _hmirvcController.videoOnDemandIsActive && AL2HMIBridge.globalSource.transmissionStatus !== AL2HMIBridge.GlobalSource.TransmissionStatusReverse
    property int aPAPopupWidth: UiTheme.styleRoot.applicationWidth

    function isvalidSappState() {
        return (AL2HMIBridge.rvcSource.sappStatus !== AL2HMIBridge.RVCSource.NoMessage
                && AL2HMIBridge.rvcSource.sappStatus !== 0
                && AL2HMIBridge.rvcSource.sappStatus !== 0xFF
                && AL2HMIBridge.rvcSource.sappStatus !== 0xFE);
    }


    function isvalidAPASappState() {
        return (AL2HMIBridge.rvcSource.sappStatus !== AL2HMIBridge.RVCSource.NoMessage
                && AL2HMIBridge.rvcSource.sappStatus !== 0);

    }

    function isvalidAPACSISystemState() {
        return (AL2HMIBridge.rvcSource.apaSystemStatus !== AL2HMIBridge.RVCSource.APASystemStatus_Null
                && AL2HMIBridge.rvcSource.apaSystemStatus !== AL2HMIBridge.RVCSource.APASystemStatus_Off)
    }

    function apaCsiHeaderText(status) {
        switch (status) {
            // Below mentioned stings are existing tring copied from different QML file
        case AL2HMIBridge.RVCSource.ParallelParkingActive:
            //~ GroupID Rvc/rvcpopup-0002
            //~ TextID 81944456-90f6-11e9-b2ac-08002718b8d7
            return qsTr("Parallel Park");
        case AL2HMIBridge.RVCSource.PerpendicularParkingActive:
            //~ GroupID Rvc/rvcpopup-0002
            //~ TextID 81944457-90f6-11e9-b2ac-08002718b8d7
            return qsTr("Perpendicular Park");
        case AL2HMIBridge.RVCSource.ParkOutAssistActive:
            //~ GroupID Rvc/rvcpopup-0002
            //~ TextID 81944458-90f6-11e9-b2ac-08002718b8d7
            return qsTr("Parallel Park Out")
        default:
            return ""
        }
    }

    transparentWindow: true

    property bool apaCsiActive: AL2HMIBridge.rvcSource.driverAssistConfiguration === AL2HMIBridge.RVCSource.RearFrontPDCWithAPACSI

    property bool fapaActive: AL2HMIBridge.rvcSource.driverAssistConfiguration === AL2HMIBridge.RVCSource.RearFrontPDCWithFAPA

    property bool showParkAssist: (_parkAssistController.parkAssistActive && isvalidAPASappState()
                                   && (AL2HMIBridge.rvcSource.activeAssistMode !== AL2HMIBridge.RVCSource.NoneActive)
                                   && (AL2HMIBridge.rvcSource.activeAssistMode !== AL2HMIBridge.RVCSource.ActiveModeOff)
                                   && !apaCsiActive && !fapaActive)
    property bool showSemiAutomaticParallelParking: _parkAssistController.semiAutomaticParallelParkingActive
                                                    && isvalidSappState()
                                                    && !_parkAssistController.showSAPPException
                                                    && !apaCsiActive && !fapaActive
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
    property bool showZoomButton: showZoomControls &&
                                  ((AL2HMIBridge.rvcSource.nonMulticameraSplitViewConfiguration && AL2HMIBridge.rvcSource.multiCamSoftButtons && AL2HMIBridge.rvcSource.nonMulticameraShowing !== AL2HMIBridge.RVCSource.NonMultiCameraInvalid) ||
                                   (!AL2HMIBridge.rvcSource.multiCamSoftButtons || AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBOff))
    property bool showCtaIcons: AL2HMIBridge.rvcSource.crossTrafficAlertEnabled && showZoomControls && !showAuxView &&
                                (AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFront360 &&
                                 AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontNormal &&
                                 AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontSplit)

    property bool showNonMultiCameraRearNormal: AL2HMIBridge.rvcSource.nonMulticameraSplitViewConfiguration
                                                && AL2HMIBridge.rvcSource.nonMulticameraShowing === AL2HMIBridge.RVCSource.NonMultiCameraRearNormal
    property bool showNonMultiCameraRearSplit: AL2HMIBridge.rvcSource.nonMulticameraSplitViewConfiguration
                                               && AL2HMIBridge.rvcSource.nonMulticameraShowing === AL2HMIBridge.RVCSource.NonMultiCameraRearSplit
    property bool showNonMultiCameraSplitView: showNonMultiCameraRearNormal || showNonMultiCameraRearSplit
    readonly property bool showCancelButtonBoundaryAlertRVC: AL2HMIBridge.rvcSource.boundaryAlertLeftActive || AL2HMIBridge.rvcSource.boundaryAlertRightActive

    property bool showCancelButton: _hmirvcController.zoomButtonsActive &&
                                    AL2HMIBridge.rvcSource.rvcDelayExit &&
                                    AL2HMIBridge.globalSource.transmissionStatus !== AL2HMIBridge.GlobalSource.TransmissionStatusReverse &&
                                    (AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFront360 &&
                                     AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontNormal &&
                                     AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBFrontSplit)
    property bool cameraViewActivatedByReverseGear : AL2HMIBridge.rvcSource.cameraActivationReason === AL2HMIBridge.RVCSource.CameraActivationReasonReverseGear

    //FORDSYNC3-51879 : This is to hide the back button from background view when RVC is visible.
    //If the back button is hidden then it will be restore when the popup visibility changed.
    onVisibleChanged: {
        if (visible)
        {
            if(_parkAssistController.rvcBackViewHasBackButton)
            {
                _statusBarController.setBackButtonVisible(false);
            }
        }
        else
        {
            if(_parkAssistController.rvcBackViewHasBackButton)
            {
                _statusBarController.setBackButtonVisible(true);
            }
        }
    }

    rootPopupContents: [
        HmiImage{
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: UiTheme.styleRoot.statusBarHeight
            source: UiTheme.palette.image(UiTheme.palette.viewBackground)
            visible: (apaCsiActive || fapaActive) && isvalidAPACSISystemState()

            TextLabel {
                width: parent.width
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -1
                horizontalAlignment: Text.AlignHCenter
                variation: HmiGui.BigLabelVariation
                text: apaCsiHeaderText(AL2HMIBridge.rvcSource.activeAssistMode)
            }
        },
        Item {
            id: container

            anchors {
                top: parent.top
                topMargin: UiTheme.styleRoot.statusBarHeight
                left: parent.left
                right: parent.right
            }
            height: _rVCPopupStyle.rvcPopupComponentHeight

            IconPushButton {
                id: zoomButton
                objectName: "RVCPopup_zoomButton"

                visible: (AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMax || AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMin)
                         && !ViewController.qrvc
                         && !showCancelButton
                         && !showCancelButtonBoundaryAlertRVC
                         && !showNonMultiCameraRearSplit
                         && showZoomButton
                         && !showSplitView
                         && !showFrontCamera
                iconId: (AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMax
                         && AL2HMIBridge.rvcSource.multicameraShowing !== AL2HMIBridge.RVCSource.IPMBChmsl)
                        || (AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMax
                            && !showNonMultiCameraRearSplit)
                        || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBRearZoom
                        || AL2HMIBridge.rvcSource.multicameraShowing === AL2HMIBridge.RVCSource.IPMBChmslZoom ? "shared/icon_mapzoom_out"
                                                                                     : "shared/icon_mapzoom_in"

                shape: HmiGui.Rectangular
                size: (AL2HMIBridge.rvcSource.multiCamSoftButtons || showNonMultiCameraRearNormal) ? HmiGui.VerySmall : HmiGui.Tiny

                active: AL2HMIBridge.globalSource.transmissionStatus === AL2HMIBridge.GlobalSource.TransmissionStatusReverse && _hmirvcController.zoomButtonsActive
                variation: (AL2HMIBridge.rvcSource.multiCamSoftButtons || showNonMultiCameraRearNormal) ? HmiGui.FloatButtonVariation : HmiGui.SolidButtonVariation

                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 14
                }
                onClicked: {
                    if (AL2HMIBridge.rvcSource.rvcZoomLevel === AL2HMIBridge.RVCSource.ZoomLevelMax) {
                        _hmirvcController.zoomOut()
                    } else {
                        _hmirvcController.zoomIn()
                    }
                }
            }

            IconPushButton {
                id: cancelButton
                objectName: "RVCPopup_cancelButton"

                visible: (showCancelButton && !ViewController.qrvc && cameraViewActivatedByReverseGear) ||
                         showCancelButtonBoundaryAlertRVC

                iconId: "shared/icon_off"
                shape: HmiGui.Rectangular
                size: (AL2HMIBridge.rvcSource.multiCamSoftButtons || showNonMultiCameraRearNormal) ? HmiGui.VerySmall : HmiGui.Tiny
                variation: (AL2HMIBridge.rvcSource.multiCamSoftButtons || showNonMultiCameraRearNormal) ? HmiGui.FloatButtonVariation : HmiGui.SolidButtonVariation

                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 14
                }

                onClicked: {
                    if (showCancelButtonBoundaryAlertRVC)
                    {
                        _hmirvcController.fastDismiss(root.instanceId)
                        _hmirvcController.boundaryAlertRVCDeactivate()
                    }
                    else
                        _hmirvcController.cancelDelayedCameraView()
                }
            }

            SAPPExceptionPanel {
                visible: _parkAssistController.showSAPPException
            }

            CrossTrafficAlertIcons {
                id: crossTrafficAlertIcons

                rightCrossTrafficAlertIconsObjectName: "RVCPopup_CrossTrafficAlertRightIcon"
                leftCrossTrafficAlertIconsObjectName : "RVCPopup_CrossTrafficAlertLeftIcon"

                anchors.rightMargin: 0
                visible: showCtaIcons
            }
        },
        HmiImage {
            id: bottomContainer
            objectName: "RVCPopup_bottomContainer"

            anchors {
                top:container.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                bottomMargin:  ((apaCsiActive || fapaActive) && isvalidAPACSISystemState()) ? 0 : UiTheme.styleRoot.navigationBarHeight
            }
            source: UiTheme.palette.image(UiTheme.palette.viewBackground)

            RVCTextLabel {
                id: textLabel
                objectName: "RVCPopup_textLabel"

                //~ GroupID Rvc/rvcpopup-0001
                //~ TextID 1a16b706-06b8-11e8-b98a-0800270422e6
                text: brakeEvent ? qsTr("BRAKE!") :
                                   //~ GroupID Rvc/rvcpopup-0001
                                   //~ TextID 1a16b756-06b8-11e8-b98a-0800270422e6
                                   showVideoOnDemand ? qsTr("Video on demand active \n Please check surroundings for safety") :
                                                       //~ GroupID Rvc/rvcpopup-0001
                                                       //~ TextID 19f54cb0-06b8-11e8-b98a-0800270422e6
                                                       qsTr("Please check surroundings for safety")
                anchors {
                    top : cameraViewButtons.bottom
                    topMargin: UiTheme.styleRoot.generalMarginSmaller + UiTheme.styleRoot.generalMarginBig
                    right: parent.right
                    left: parent.left
                }
                horizontalAlignment: Text.AlignHCenter
                visible: showZoomButton
                wrapMode: Text.WordWrap
                variation: HmiGui.BigLabelVariation
            }

            APACameraText {
                aPACameraBottomTextObjectName : "RVCPopup_APACameraBottomText"
                aPACameraHeaderTextObjectName : "RVCPopup_APACameraHeaderText"
                aPACameraTextIconObjectName  : "RVCPopup_APACameraTextIcon"
                showPDC: !showSplitView && !show360View

                visible: showParkAssist
            }


            APACSICameraText {
                visible: (apaCsiActive || fapaActive) && isvalidAPACSISystemState()
            }

            SAPPCameraText {
                sAPPCameraLeftIconObjectName:  "RVCPopup_SAPPCameraLeftIcon"
                sAPPCameraRightIconObjectName : "RVCPopup_SAPPCameraRightIcon"
                visible: showSemiAutomaticParallelParking
            }

            CameraViewButtons {
                id:cameraViewButtons
                cameraButtonObjectName : "RVCPopup_cameraViewButtons"

                expendableMode: false
                anchors {
                    top: parent.top
                    topMargin: UiTheme.styleRoot.generalMarginBig
                    horizontalCenter: parent.horizontalCenter
                }
                height: childrenRect.height
                width: aPAPopupWidth
                visible: !showParkAssist && !showSemiAutomaticParallelParking && AL2HMIBridge.rvcSource.multiCamSoftButtons
                         && !((apaCsiActive || fapaActive) && isvalidAPACSISystemState())
            }

            IconPushButton {
                id: nonMultiCameraButton
                objectName: "RVCPopup_nonMultiCameraButton"

                visible: showZoomButton && showNonMultiCameraSplitView

                iconId: showNonMultiCameraRearNormal ? "parkingfeatures/icon_rear_split_view" :
                                                       showNonMultiCameraRearSplit ? "parkingfeatures/icon_rear_view" : ""


                shape: HmiGui.Rectangular
                size: HmiGui.VerySmall
                anchors {
                    top: parent.top
                    topMargin: UiTheme.styleRoot.generalMarginBig
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    _hmirvcController.nonMultiCameraSoftButtonPress()
                }
            }

            ParkDistanceControl {
                id: pdcImage
                objectName: "ZoomControls_pdcImage"


                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 50
                }
                visible: showZoomButton
            }
        }
    ]
}
