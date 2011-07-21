package com.projectcocoon.p2p.managers
{
	import com.projectcocoon.p2p.NetStatusCode;
	import com.projectcocoon.p2p.command.CommandList;
	import com.projectcocoon.p2p.command.CommandType;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.GroupEvent;
	import com.projectcocoon.p2p.events.MediaBroadcastEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.events.ObjectEvent;
	import com.projectcocoon.p2p.interfaces.IGroupConnection;
	import com.projectcocoon.p2p.util.GroupCreator;
	import com.projectcocoon.p2p.util.Tracer;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.projectcocoon.p2p.vo.GroupInfoVO;
	import com.projectcocoon.p2p.vo.MediaVO;
	import com.projectcocoon.p2p.vo.MessageVO;
	import com.projectcocoon.p2p.vo.ObjectMetadataVO;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Dictionary;

	[Event(name="groupConnected", type="com.projectcocoon.p2p.events.GroupEvent")]
	[Event(name="groupClosed", type="com.projectcocoon.p2p.events.GroupEvent")]
	[Event(name="clientAdded", type="com.projectcocoon.p2p.events.ClientEvent")]
	[Event(name="clientUpdate", type="com.projectcocoon.p2p.events.ClientEvent")]
	[Event(name="clientRemoved", type="com.projectcocoon.p2p.events.ClientEvent")]
	[Event(name="dataReceived", type="com.projectcocoon.p2p.events.MessageEvent")]
	[Event(name="objectAnnounced", type="com.projectcocoon.p2p.events.ObjectEvent")]
	[Event(name="objectRequest", type="com.projectcocoon.p2p.events.ObjectEvent")]
	[Event(name="mediaBroadcast", type="com.projectcocoon.p2p.events.MediaBroadcastEvent")]
	
	public class GroupManager extends EventDispatcher implements IGroupConnection
	{
		
		private var netConnection:NetConnection;
		private var groups:Dictionary = new Dictionary();
		private var multicastAddress:String;
		
		public function GroupManager(netConnection:NetConnection, multicastAddress:String)
		{
			this.netConnection = netConnection;
			this.netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 9999);
			this.multicastAddress = multicastAddress;
		}
		
		/*** 
		 * 
		 * Each media publisher needs <code>serverChannelEnabled = true</code>in the GroupSpecifier, 
		 * 	which avoids flushing data from the network when disconnected
		 * Not fully aware of the design of the GroupManager, simply asking a group with different settings (testing, v 0.8.1) 
		 * 
		 * Mario Vieira
		 * 
		 ***/  
		public function createMediaBroadcastNetGroup(name:String):GroupSpecifier
		{
			var groupSpec:GroupSpecifier = GroupCreator.getMediaGroupSpecifier(name, multicastAddress);
			GroupCreator.getObservedGroup(groupSpec, netConnection, netStatusHandler, groups);
			
			return groupSpec;
		}

		public function createNetGroup(name:String):NetGroup
		{
			return GroupCreator.getObservedGroup( GroupCreator.getDefaultGroupSpecifier(name, multicastAddress), netConnection, netStatusHandler, groups );
		}
		
		public function get groupNetConnection():NetConnection
		{
			return netConnection;
		}
		
		public function leaveNetGroup(netGroup:NetGroup):void
		{
			netGroup.close();
		}
		
		public function announceToGroup(netGroup:NetGroup):MessageVO
		{
			return sendMessageToAll(null, netGroup, CommandType.SERVICE, CommandList.ANNOUNCE_NAME);
		}
		
		public function sendMessageToAll(value:Object, netGroup:NetGroup, type:String = CommandType.MESSAGE, command:String = null):MessageVO
		{
			//Tracer.log(this, "sendMessageToAll - command: "+command+" value: "+value);
			var client:ClientVO = getLocalClient(netGroup);
			if (client)
			{
				var msg:MessageVO = new MessageVO(client, value, null, type, command);
				netGroup.post(msg);
				return msg;
			}
			return null;
		}
		
		public function sendMessageToClient(value:Object, netGroup:NetGroup, client:ClientVO, type:String = CommandType.MESSAGE, command:String = null):MessageVO
		{
			return sendMessageToGroupAddress(value, netGroup, client.groupID, type, command);
		}
		
		public function sendMessageToGroupAddress(value:Object, netGroup:NetGroup, groupAddress:String,type:String = CommandType.MESSAGE, command:String = null):MessageVO
		{
			var client:ClientVO = getLocalClient(netGroup);
			if (client)
			{
				var msg:MessageVO = new MessageVO(client, value, groupAddress, type, command);
				netGroup.sendToNearest(msg, groupAddress);
				return msg;
			}
			return null;
		}
		
		public function getLocalClient(netGroup:NetGroup):ClientVO
		{
			return getClient(netGroup, netConnection.nearID);
		}
		
		public function getClient(netGroup:NetGroup, peerID:String):ClientVO
		{
			var groupInfo:GroupInfoVO = groups[netGroup];
			if (groupInfo)
			{
				return getClientByPeerID(groupInfo, peerID);
			}
			return null;
		}
		
		public function getClients(netGroup:NetGroup):Vector.<ClientVO>
		{
			var groupInfo:GroupInfoVO = groups[netGroup];
			if (groupInfo)
			{
				return groupInfo.clients;
			}
			return new Vector.<ClientVO>();
		}
		
		public function getGroupspecWithAuthorizations(netGroup:NetGroup):String
		{
			var groupInfo:GroupInfoVO = groups[netGroup];
			return (groupInfo) ? groupInfo.groupSpec : null;
		}
		
		
		// ============= Private ============= //
		
		private function getClientByPeerID(groupInfo:GroupInfoVO, peerID:String):ClientVO
		{
			for each (var client:ClientVO in groupInfo.clients)
			{
				if (client.peerID == peerID)
					return client;
			}
			return null;
		}
		
		private function groupConnected(netGroup:NetGroup):void
		{
			addNeighbour(netGroup, netConnection.nearID, true);
			dispatchEvent(new GroupEvent(GroupEvent.GROUP_CONNECTED, netGroup));
			// adds the local client to the list of peers in the NetGroup
		}

		private function addNeighbour(netGroup:NetGroup, peerID:String, isLocal:Boolean = false):void
		{
			var groupInfo:GroupInfoVO = groups[netGroup];
			if (groupInfo)
			{
				if (!getClientByPeerID(groupInfo, peerID))
				{
					var client:ClientVO = new ClientVO();
					client.peerID = peerID;
					client.groupID = netGroup.convertPeerIDToGroupAddress(client.peerID);
					client.isLocal = isLocal;
					groupInfo.clients.push(client);
					dispatchEvent(new ClientEvent(ClientEvent.CLIENT_ADDED, client, netGroup));
				}
			}
		}
		
		private function removeNeighbour(netGroup:NetGroup, peerID:String):void
		{
			var groupInfo:GroupInfoVO = groups[netGroup];
			if (groupInfo)
			{
				var client:ClientVO = getClientByPeerID(groupInfo, peerID);
				if (!client)
					return;
				var idx:int = groupInfo.clients.indexOf(client)
				if (idx > -1)
				{
					groupInfo.clients.splice(idx, 1);
					dispatchEvent(new ClientEvent(ClientEvent.CLIENT_REMOVED, client, netGroup));
				}
			}
		}
		
		private function handleSendTo(event:NetStatusEvent):void
		{
			var message:MessageVO = event.info.message as MessageVO;
			
			if (!message)
				return;
			
			if (event.info.fromLocal == true) 
			{
				if (message.command == CommandList.ANNOUNCE_SHARING)
				{
					dispatchEvent(new ObjectEvent(ObjectEvent.OBJECT_ANNOUNCED, message.data as ObjectMetadataVO));
				}
				else
				{
					dispatchEvent(new MessageEvent(MessageEvent.DATA_RECEIVED, message, event.target as NetGroup));
				}
			} 
			else 
			{
				event.target.sendToNearest(message, message.destination);
			}
		}
		
		private function handlePosting(event:NetStatusEvent):void
		{
			var message:MessageVO = event.info.message as MessageVO;
				
			if (!message)
				return;
			
			var group:NetGroup = event.target as NetGroup; 
			var groupInfo:GroupInfoVO = groups[group];
			
			//Tracer.log(this, "handlePosting - message.type: "+message.type+"  message.command: "+message.command);
			
			if (message.type == CommandType.SERVICE) 
			{
				if (message.command == CommandList.ANNOUNCE_NAME) 
				{
					for each (var client:ClientVO in groupInfo.clients) 
					{
						if(client.groupID == message.client.groupID) 
						{
							client.clientName = message.client.clientName;
							dispatchEvent(new ClientEvent(ClientEvent.CLIENT_UPDATE, client, group));
							break;
						}
					}
				}
				else if (message.command == CommandList.ANNOUNCE_SHARING)
				{
					dispatchEvent(new ObjectEvent(ObjectEvent.OBJECT_ANNOUNCED, message.data as ObjectMetadataVO));
				}
				else if (message.command == CommandList.REQUEST_OBJECT)
				{
					dispatchEvent(new ObjectEvent(ObjectEvent.OBJECT_REQUEST, message.data as ObjectMetadataVO));
				}
				else if (message.command == CommandList.MEDIA_BROADCAST)
				{
					//Tracer.log(this, "handlePosting - dispatchEvent(new MediaEvent: "+(message.data as MediaVO)+")");
					dispatchEvent(new MediaBroadcastEvent(MediaBroadcastEvent.MEDIA_BROADCAST, message.data as MediaVO, message.client));
				}
			} 
			else if (message.type == CommandType.MESSAGE)
			{
				dispatchEvent(new MessageEvent(MessageEvent.DATA_RECEIVED, message, group));
			}
		}		
				
		private function cleanup(netGroup:NetGroup):void
		{
			netGroup.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			try
			{
				netGroup.close();	
			}
			catch (e:Error)
			{
			}
			delete groups[netGroup];
			dispatchEvent(new GroupEvent(GroupEvent.GROUP_CLOSED, netGroup));
		}
		
		private function cleanupAll():void
		{
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			for (var netGroup:* in groups)
			{
				netGroup.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				try
				{
					netGroup.close();	
				}
				catch (e:Error)
				{
				}
			}
			groups = null;
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			//Tracer.log(this, "onNetStatus - evt.info.code: "+event.info.code );
			switch (event.info.code) 
			{
				case NetStatusCode.NETGROUP_CONNECT_SUCCESS:
					groupConnected(event.info.group as NetGroup);
					break;
				case NetStatusCode.NETGROUP_NEIGHBOUR_CONNECT:
					addNeighbour(event.target as NetGroup, event.info.peerID);
					break;
				case NetStatusCode.NETGROUP_NEIGHBOUR_DISCONNECT:
					removeNeighbour(event.target as NetGroup, event.info.peerID);
					break;
				case NetStatusCode.NETGROUP_POSTING_NOTIFY:
					handlePosting(event);
					break;
				case NetStatusCode.NETGROUP_SENDTO_NOTIFY:
					handleSendTo(event);
					break;
				case NetStatusCode.NETGROUP_CONNECT_CLOSED:
				case NetStatusCode.NETGROUP_CONNECT_FAILED:
				case NetStatusCode.NETGROUP_CONNECT_REJECTED:
					cleanup(event.info.group as NetGroup);
					break;
				case NetStatusCode.NETCONNECTION_CONNECT_FAILED:
				case NetStatusCode.NETCONNECTION_CONNECT_CLOSED:
					cleanupAll();
					break;
			}
		}
		
		public function disconnect():void
		{
			cleanupAll();
		}
	}
	
}