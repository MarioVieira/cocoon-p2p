package com.projectcocoon.p2p.interfaces
{
	import com.projectcocoon.p2p.vo.ClientVO;
	
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;

	public interface ILocalNetworkInfo
	{
		function get localClient()							:ClientVO;
		function get localClientGroupspecWithAuthorization():String;
	}
}