package com.projectcocoon.p2p.managers
{
	import com.projectcocoon.p2p.NetStatusCode;
	import com.projectcocoon.p2p.enums.MediaEnums;
	import com.projectcocoon.p2p.interfaces.IGroupConnection;
	import com.projectcocoon.p2p.interfaces.ILocalNetworkInfo;
	import com.projectcocoon.p2p.interfaces.IMediaMessenger;
	import com.projectcocoon.p2p.util.GetMediaInfo;
	import com.projectcocoon.p2p.util.Tracer;
	import com.projectcocoon.p2p.vo.BroadcasterVo;
	import com.projectcocoon.p2p.vo.MediaVO;
	
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	
	/**
	 * 
	 * @author Mario Vieira
	 * 
	 */	
	public class MediaManager
	{
		private var _groupConnection	:	IGroupConnection;
		private var _mediaMessenger		:	IMediaMessenger;
		private var _localClientInfo	:	ILocalNetworkInfo;
		private var _mediaInfo			:	MediaVO;
		private var _camAndMic			:	BroadcasterVo;
		private var _sendStream 		:	NetStream;
		
		
		public function MediaManager(groupConnection:IGroupConnection, mediaMessenger:IMediaMessenger, localClientInfo:ILocalNetworkInfo)
		{
			_localClientInfo = localClientInfo;
			_groupConnection = groupConnection;
			_mediaMessenger	 = mediaMessenger;
			_mediaInfo		 = new MediaVO();
		}
		
		public function startMedia(broadcasterInfo:BroadcasterVo):void
		{	
			var type:String = GetMediaInfo.getMediaType(broadcasterInfo); 
			//Tracer.log(this,"udpated 8.6 - startMedia() - type: "+type+"  broadcasting: "+_mediaInfo.broadcasting);
			if(type && !_mediaInfo.broadcasting)
			{ 
				_camAndMic = broadcasterInfo;
				publishMedia(type);
			}
		}
		
		public function stopMedia():void
		{
			_mediaInfo.mediaType	= null;
			_mediaInfo.broadcasting = false;
			_camAndMic.camera 		= null;
			_camAndMic.microphone 	= null;
			
			_sendStream.close();
		}
		
		private function publishMedia(type:String):void
		{
			setupNetStream();
			_mediaInfo.broadcasting	   					   = true;
			_mediaInfo.mediaType 	   					   = type;
			_mediaInfo.publisherFarID  					   = _localClientInfo.localClient.peerID;
			_mediaInfo.publisherGroupspecWithAuthorization = _localClientInfo.localClientGroupspecWithAuthorization;
			
			//Tracer.log(this,"publishMedia - _localClientInfo: "+ _localClientInfo +" type: "+type+"  stream name: "+GetMediaInfo.getStreamName(_mediaInfo)+"  _groupConnection: "+_groupConnection+" _mediaInfo.publisherGroupspecWithAuthorization : "+_mediaInfo.publisherGroupspecWithAuthorization);
			
			
			_mediaInfo.publisherStream = GetMediaInfo.getStreamName(_mediaInfo);
			setNetStreamClient();
			
			//THIS IS INCORRECT, NOT POSSIBLE TO STREAM DIRECTTLY, need to use appendBytes of NetStream 
			attachAudioAndVideo();
			
			Tracer.log(this, "publishMedia - publisherStream: "+_mediaInfo.publisherStream);
			_sendStream.publish(_mediaInfo.publisherStream);
		}
		
		private function setupNetStream():void
		{
			if(!_sendStream) 
			{
				Tracer.log(this, "setupNetStream - gSpec: "+_localClientInfo.localClientGroupspecWithAuthorization);
				_sendStream = new NetStream(_groupConnection.groupNetConnection, _localClientInfo.localClientGroupspecWithAuthorization);
				_sendStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
		}
		
		private function setNetStreamClient():void
		{
			var sendStreamClient:Object = new Object();
			
			sendStreamClient.onPeerConnect = function(callerns:NetStream):Boolean
			{
				//_mediaInfo.publisherFarID = callerns.farID;
				Tracer.log(this,"_sendStream.client.sendStreamClient.onPeerConnect "+callerns.farID);
				return true;
			}	
			
			_sendStream.client = sendStreamClient;
		}
		
		/**
		 * Only called when NetConnection is stablished 
		 * 
		 */		
		private function attachAudioAndVideo():void
		{
			if(_mediaInfo.mediaType == MediaEnums.MIC)
			{
				//Tracer.log(this, "attachAudioAndVideo - attach mic");
				_sendStream.attachAudio(_camAndMic.microphone);
			}
			else if(_mediaInfo.mediaType == MediaEnums.CAM_AND_MIC)
			{
				//Tracer.log(this, "attachAudioAndVideo - attach mic and cam");
				_sendStream.attachAudio(_camAndMic.microphone);
				_sendStream.attachCamera(_camAndMic.camera);
			}
			else if(_mediaInfo.mediaType == MediaEnums.CAM)
			{
				//Tracer.log(this, "attachAudioAndVideo - attach cam");
				_sendStream.attachCamera(_camAndMic.camera);
			}
		}
		
		protected function broadcastMediaInfoChange(mediaType:MediaVO):void
		{
			//Tracer.log(this, "broadcastMediaInfoChange - mediaType: "+mediaType);
			_mediaMessenger.sendMediaMessageToAll(mediaType);
		}
		
		protected function getMicrophoneConfiguration():SoundTransform
		{
			var soundTrans:SoundTransform = new SoundTransform();
			soundTrans.volume = 6;
			return soundTrans;
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{  
			Tracer.log( this, "onNetStatus - event.info: "+event.info.code.toString() );
			switch (event.info.code) 
			{
				case NetStatusCode.NETSTREAM_START:
					broadcastMediaInfoChange(_mediaInfo);
					break;
			}
		}
	}
}