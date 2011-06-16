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
		public static function getMediaGroupSpecifier(groupName:String, multicastAddress:String):GroupSpecifier
		{
			var groupSpec:GroupSpecifier = new GroupSpecifier(groupName + MediaEnums.MEDIA_GROUP);
			
			groupSpec.postingEnabled 		= true;
			groupSpec.serverChannelEnabled 	= true;
			groupSpec.multicastEnabled 		= true;
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.addIPMulticastAddress(multicastAddress);
			
			return groupSpec;
		}
		
		public static function getDefaultGroupSpecifier(groupName:String, multicastAddress:String):GroupSpecifier
		{
			var groupSpec:GroupSpecifier = new GroupSpecifier(groupName);
			
			// needs to force this in case it was connected
			groupSpec.serverChannelEnabled 	= false;
			groupSpec.postingEnabled 		= true;
			groupSpec.routingEnabled 		= true;
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.multicastEnabled 			= true;
			groupSpec.objectReplicationEnabled  = true;
			groupSpec.addIPMulticastAddress(multicastAddress);
			groupSpec.serverChannelEnabled 		= true;
			
			return groupSpec;
		}
		
		/*** 
		 * 
		 * Each media publisher needs <code>multicastEnabled = true</code>in the GroupSpecifier
		 * Not fully aware of the design of the GroupManager, simply asking a group with different settings 
		 * 
		 * Mario Vieira
		 * 
		 ***/  
		
		public static function getObservedGroup(groupSpec:GroupSpecifier, netConnection:NetConnection, netStatusHandler:Function, groups:Dictionary):NetGroup
		{
			var groupSpecString:String = groupSpec.groupspecWithAuthorizations();
			var group:NetGroup = new NetGroup(netConnection, groupSpecString);
			group.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 9999);
			
			if(groups)
			{
				var groupInfo:GroupInfoVO = new GroupInfoVO(groupSpecString);
				groups[group] = groupInfo;
			}
			
			return group;
		}
	}
}