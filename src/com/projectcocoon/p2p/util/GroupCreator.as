package com.projectcocoon.p2p.util
{
	import com.projectcocoon.p2p.enums.MediaEnums;
	import com.projectcocoon.p2p.vo.GroupInfoVO;
	
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Dictionary;

	public class GroupCreator
	{
		/*** 
		 * 
		 * Each media publisher needs <code>multicastEnabled = true</code>in the GroupSpecifier
		 * Not fully aware of the design of the GroupManager, simply asking a group with different settings 
		 * 
		 * Mario Vieira
		 * 
		 ***/  
		public static function createMediaBroadcastNetGroup(name:String, multicastAddress:String, netConnection:NetConnection, netStatusHandler:Function, groups:Dictionary):NetGroup
		{
			var groupSpec:GroupSpecifier = new GroupSpecifier(name + MediaEnums.MEDIA_GROUP);
			
			groupSpec.postingEnabled 		= true;
			groupSpec.serverChannelEnabled 	= true;
			groupSpec.multicastEnabled 		= true;
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.addIPMulticastAddress(multicastAddress);
			
			return getObservedGroup(groupSpec, netConnection, netStatusHandler, groups);
		}
		
		public static function createNetGroup(name:String, multicastAddress:String, netConnection:NetConnection, netStatusHandler:Function, groups:Dictionary):NetGroup
		{
			var groupSpec:GroupSpecifier = new GroupSpecifier(name);
			groupSpec.postingEnabled = true;
			groupSpec.routingEnabled = true;
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.objectReplicationEnabled = true;
			groupSpec.addIPMulticastAddress(multicastAddress);
			groupSpec.serverChannelEnabled = true;
			
			return getObservedGroup(groupSpec, netConnection, netStatusHandler, groups);
		}
		
		private static function getObservedGroup(groupSpec:GroupSpecifier, netConnection:NetConnection, netStatusHandler:Function, groups:Dictionary):NetGroup
		{
			var groupSpecString:String = groupSpec.groupspecWithAuthorizations();
			var group:NetGroup = new NetGroup(netConnection, groupSpecString);
			group.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 9999);
			
			var groupInfo:GroupInfoVO = new GroupInfoVO(groupSpecString);
			groups[group] = groupInfo;
			return group;
		}
	}
}