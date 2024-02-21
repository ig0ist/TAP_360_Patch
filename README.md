# Main idea 

For Sync3 

> [!WARNING]
> Work only on IPMB & 360 &3.4.23188
> 
> Mod not tested by autoInstall, manual code change - work
> 

If you click on the *bottom half* of the screen, the camera switches


## QML Elemet 

```javascript


Rectangle {
    id: redBTT
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    width: parent.width
    height: parent.height / 2
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            setNewCameraStatus();
        }
    }
}


```

## Code JS 

```javascript


function setNewCameraStatus()
{
    var setCamera = false;

    switch (AL2HMIBridge.rvcSource.multicameraShowing) {
        // Front
        case AL2HMIBridge.RVCSource.IPMBFront360: setCamera = AL2HMIBridge.RVCSource.IPMBFrontNormal; break;
        case AL2HMIBridge.RVCSource.IPMBFrontNormal: setCamera = AL2HMIBridge.RVCSource.IPMBFrontSplit; break;
        case AL2HMIBridge.RVCSource.IPMBFrontSplit: setCamera = AL2HMIBridge.RVCSource.IPMBFrontNormal; break;
        // Rear
        case AL2HMIBridge.RVCSource.IPMBRear360: setCamera = AL2HMIBridge.RVCSource.IPMBRearNormal; break;
        case AL2HMIBridge.RVCSource.IPMBRearSplit: setCamera = AL2HMIBridge.RVCSource.IPMBRearNormal; break;
        case AL2HMIBridge.RVCSource.IPMBRear: setCamera = AL2HMIBridge.RVCSource.IPMBRearSplit; break;
        case AL2HMIBridge.RVCSource.IPMBRearNormal: setCamera = AL2HMIBridge.RVCSource.IPMBRearSplit; break;
        default:
            break;
    }
    if (setCamera) {
        _hmirvcController.selectRVCView(setCamera)
    }
}


```