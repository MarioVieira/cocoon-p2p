package com.projectcocoon.p2p.util
{
	import com.projectcocoon.p2p.enums.MediaEnums;
	import com.projectcocoon.p2p.vo.BroadcasterVo;
	import com.projectcocoon.p2p.vo.MediaVO;

	public class GetMediaInfo
	{
		public static function getStreamName(mediaInfo:MediaVO):String
		{
			return mediaInfo.mediaType + new Date().getTime();//mediaInfo.client.peerID;
		}
		
		public static function getMediaType(mediaInfo:BroadcasterVo):String
		{
			if(mediaInfo.camera && mediaInfo.microphone)
			{
				return MediaEnums.CAM_AND_MIC;
			}
			else if(mediaInfo.microphone)
			{
				return MediaEnums.MIC;
			}
			else if(mediaInfo.camera)
			{
				return MediaEnums.CAM;
			}
			
			return null;
		}
	}
}