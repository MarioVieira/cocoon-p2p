package com.projectcocoon.p2p.interfaces
{
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;

	public interface IGroupConnection
	{
		function get groupNetConnection():NetConnection;
		function createMediaBroadcastNetGroup(name:String):GroupSpecifier;
	}
}