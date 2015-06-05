using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class ITPhoneManager {
#if (UNITY_IPHONE || UNITY_IOS) && !UNITY_EDITOR
	[DllImport("__Internal")]
	private static extern string _getNetworkOperator();
	[DllImport("__Internal")]
	private static extern string _getMCC();
	[DllImport("__Internal")]
	private static extern string _getMNC();
	[DllImport("__Internal")]
	private static extern void _setKeyChainValue(string key, string value);
	[DllImport("__Internal")]
	private static extern string _getKeyChainValue(string key);
#endif
	
#if UNITY_ANDROID && !UNITY_EDITOR
	private static AndroidJavaObject _telephonyManager = null;
	public static AndroidJavaObject telephonyManager {
		get {
			if (_telephonyManager == null)
			{
				_telephonyManager = new AndroidJavaObject("android.telephony.TelephonyManager");
			}
			return _telephonyManager;
		}
	}
#endif

	public static string getUDID()
	{
		string value = "";
#if (UNITY_IPHONE || UNITY_IOS) && !UNITY_EDITOR
		string key = "udid";
		value = _getKeyChainValue(key);
		if (string.IsNullOrEmpty(value))
		{
			value = SystemInfo.deviceUniqueIdentifier;
			_setKeyChainValue(key, value);
		}
#else
		value = SystemInfo.deviceUniqueIdentifier;
#endif
		return value;
	}

	public static string getNetworkOperator()
	{
		string value = "";
#if (UNITY_IPHONE || UNITY_IOS) && !UNITY_EDITOR
		value = _getNetworkOperator();
#elif UNITY_ANDROID && !UNITY_EDITOR
		value = telephonyManager.Call<string>("getNetworkOperator");
#endif
		return value;
	}

	public static string getMCC()
	{
		string value = "";
#if (UNITY_IPHONE || UNITY_IOS) && !UNITY_EDITOR
		value = _getMCC();
#elif UNITY_ANDROID && !UNITY_EDITOR
		string networkOperator = getNetworkOperator();
		if (!string.IsNullOrEmpty(networkOperator))
			value = networkOperator.Substring(0, 3);
#endif
		return value;
	}

	public static string getMNC()
	{
		string value = "";
#if (UNITY_IPHONE || UNITY_IOS) && !UNITY_EDITOR
		value = _getMNC();
#elif UNITY_ANDROID && !UNITY_EDITOR
		string networkOperator = getNetworkOperator();
		if (!string.IsNullOrEmpty(networkOperator))
			value = networkOperator.Substring(3);
#endif
		return value;
	}
}
