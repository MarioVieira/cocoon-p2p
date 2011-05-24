package com.projectcocoon.p2p.interfaces
{
	import com.projectcocoon.p2p.vo.MediaVO;

	public interface IMediaMessenger
	{
		function sendMediaMessage(message:MediaVO, groupID:String):void;
		function sendMediaMessageToAll(message:MediaVO):void;
	}
}