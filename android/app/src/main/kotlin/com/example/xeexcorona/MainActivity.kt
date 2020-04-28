package com.example.xeexcorona

import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.le.ScanSettings
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanCallback
import androidx.annotation.NonNull;
import android.util.Log;
import android.os.ParcelUuid
import android.os.Handler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "bluetooth-mac-address";
    private var isAdvertising = false ;
    private val uuid = "c98f994a-3c7b-49af-9b0e-36976f272803";
    private var charLength = 3;
    // private var advertiser: BluetoothLeAdvertiser!? = null;
    private val settings = AdvertiseSettings.Builder()
        .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
        .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_POWER)
        .setConnectable(true)
        .setTimeout(0)
        .build()

    private val pUuid = ParcelUuid(UUID.fromString(uuid));

    val randomUUID = UUID.randomUUID().toString()
    val finalString = randomUUID.substring(randomUUID.length - charLength, randomUUID.length)
    // print("Unique string: " + finalString);
    val serviceDataByteArray = finalString.toByteArray()
    var datas = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .setIncludeTxPowerLevel(true)
            .addServiceUuid(pUuid)
            // .addServiceData(pUuid)
            .addManufacturerData(1023, serviceDataByteArray)
            .build()

    val advertisingCallback: AdvertiseCallback =  object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings){
            print("succeess advertisisng");
            isAdvertising = true
            super.onStartSuccess(settingsInEffect);
        }
        
        override fun onStartFailure(errorCode: Int){
            // print("Advertising onStartFailure: " + errorCode );
            Log.e( "BLE", "Advertising onStartFailure: " + errorCode );
            super.onStartFailure(errorCode);
            var reason: String

            when (errorCode) {
                ADVERTISE_FAILED_ALREADY_STARTED -> {
                    reason = "ADVERTISE_FAILED_ALREADY_STARTED"
                    isAdvertising = true
                }
                ADVERTISE_FAILED_FEATURE_UNSUPPORTED -> {
                    reason = "ADVERTISE_FAILED_FEATURE_UNSUPPORTED"
                    isAdvertising = false
                }
                ADVERTISE_FAILED_INTERNAL_ERROR -> {
                    reason = "ADVERTISE_FAILED_INTERNAL_ERROR"
                    isAdvertising = false
                }
                ADVERTISE_FAILED_TOO_MANY_ADVERTISERS -> {
                    reason = "ADVERTISE_FAILED_TOO_MANY_ADVERTISERS"
                    isAdvertising = false
                }
                ADVERTISE_FAILED_DATA_TOO_LARGE -> {
                    reason = "ADVERTISE_FAILED_DATA_TOO_LARGE"
                    isAdvertising = false
                    charLength--
                }

                else -> {
                    reason = "UNDOCUMENTED"
                }
            }

            Log.e("BLE", "Advertising onStartFailure: "+ errorCode + "-" + reason)
        }
    };

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call, result ->
          // Note: this method is invoked on the main thread.
            if (call.method == "getMacAddress") {
                val address = getMacAddress()
                if (address != null) {
                    result.success(address)
                } else {
                    result.error("UNAVAILABLE", "Bluetooth mac address not available.", null)
                }
            } else if (call.method == "startAdvertising"){
                Log.v("BLE", "call advertisinng method in native");
                var advertise = startAdvertise(settings, datas, advertisingCallback );
                if (advertise != null) {
                    result.success(advertise)
                } else {
                    result.error("UNAVAILABLE", "Not advertising", null)
                }
            }else if (call.method == "startScan"){
                Log.v("BLE", "call scannig method in native");
                startScan();
                if (scanResults != null) {
                    result.success(scanResults)
                } else {
                    result.error("UNAVAILABLE", "Not scannig", null)
                }
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun getMacAddress(): String {
        var name: String? = null ;
        var BA = BluetoothAdapter.getDefaultAdapter();    
        name = BA.getAddress();
        if(name == null){
            name = BA.getName();
        }
        return name;
    }

    private fun startAdvertise(settings: AdvertiseSettings, datas: AdvertiseData, advertisingCallback: AdvertiseCallback): Boolean {
        if( !BluetoothAdapter.getDefaultAdapter().isMultipleAdvertisementSupported() ) {
            Log.e("BLE advertise", "This app don't support bluetooth advertising");
            return false
        }
        print(finalString);
        var advertiser = BluetoothAdapter.getDefaultAdapter().getBluetoothLeAdvertiser();
        advertiser.startAdvertising( settings, datas, advertisingCallback );
        return isAdvertising;
    }

    private var scanResult : ScanResult? = null
    private var scanResults : List<ScanResult> = mutableListOf<ScanResult>()
    val mScanCallback:ScanCallback = object : ScanCallback() {
        
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            super.onScanResult(callbackType, result);
            if( result == null
                    || result.getDevice() == null
                    )
                return;
            Log.v("Scan", "result on :" + result);
            scanResult = result
        }
        
        override fun onBatchScanResults(results:List<ScanResult>) {
            super.onBatchScanResults(results);
            Log.v("Scan", "result on :" + results);
            scanResults = results
        }
        
        override fun onScanFailed(errorCode:Int) {
            Log.e( "BLE", "Discovery onScanFailed: " + errorCode );
            super.onScanFailed(errorCode);
        }
    };

    var settingsScan = ScanSettings.Builder()
        .setScanMode( ScanSettings.SCAN_MODE_LOW_LATENCY )
        .build();

    fun startScan() {
        var mBluetoothLeScanner = BluetoothAdapter.getDefaultAdapter().getBluetoothLeScanner();
        // private var mHandler: Handler = Handler();
        mBluetoothLeScanner.startScan(null, settingsScan, mScanCallback);
    }
}
