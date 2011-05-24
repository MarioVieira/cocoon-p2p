package com.projectcocoon.p2p.util
{
	import com.projectcocoon.p2p.command.CommandList;
	import com.projectcocoon.p2p.command.CommandType;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.MediaBroadcastEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.events.ObjectEvent;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.projectcocoon.p2p.vo.MediaVO;
	import com.projectcocoon.p2p.vo.MessageVO;
	import com.projectcocoon.p2p.vo.ObjectMetadataVO;
	
	import flash.net.NetGroup;

	public class PostOfficer
	{
		public static function handlePostage(event:MessageEvent):void
		{
			/*var message:MessageVO = event.info.message as MessageVO;
			
			if (!message)
				return;
			
			var group:NetGroup = event.target as NetGroup; 
			var groupInfo:GroupInfo = groups[group];
			
			Tracer.log(this, "handlePosting - message.type: "+message.type+"  message.command: "+message.command);
			
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
					Tracer.log(this, "handlePosting - dispatchEvent(new MediaEvent: "+(message.data as MediaVO)+")");
					dispatchEvent(new MediaBroadcastEvent(MediaBroadcastEvent.MEDIA_BROADCAST, message.data as MediaVO));
				}
			} 
			else if (message.type == CommandType.MESSAGE)
			{
				dispatchEvent(new MessageEvent(MessageEvent.DATA_RECEIVED, message, group));
			}*/
		}
	}
}