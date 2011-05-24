package com.projectcocoon.p2p.interfaces
{
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;

	public interface IGroupConnection
	{
		function get groupNetConnection():NetConnection;
	}
}