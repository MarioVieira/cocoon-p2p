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
	import flash.media.SoundTransform;
	import flash.net.GroupSpecifier;
	import flash.net.NetStream;
	
	import org.osflash.signals.Signal;
	
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
		private var _mediaGroupSpec		:	GroupSpecifier;
		private var _netStreamSignal	:	Signal;
		
		public function MediaManager(groupConnection:IGroupConnection, mediaMessenger:IMediaMessenger, localClientInfo:ILocalNetworkInfo)
		{
			_localClientInfo = localClientInfo;
			_groupConnection = groupConnection;
			_mediaMessenger	 = mediaMessenger;
			_mediaInfo		 = new MediaVO();
			_netStreamSignal = new Signal();
		}
	
		public function get netStreamSignal():Signal
		{
			return _netStreamSignal;
		}
		
		public function get camAndMic():BroadcasterVo
		{
			return _camAndMic;
		}
		
		public function startMedia(broadcasterInfo:BroadcasterVo, order:String, backNotFrontCamera:Boolean):void
		{	
			var type:String = GetMediaInfo.getMediaType(broadcasterInfo); 
			//Tracer.log(this,"udpated 8.6 - startMedia() - type: "+type+"  broadcasting: "+_mediaInfo.broadcasting);
			if(type && !_mediaInfo.broadcasting)
			{ 
				if(_sendStream) stopMedia();
				_camAndMic = broadcasterInfo;
				publishMedia(type, order, backNotFrontCamera);
			}
		}
		
		public function get mediaInfo():MediaVO
		{
			return _mediaInfo;
		}
		
		public function stopMedia():void
		{
			_mediaInfo.mediaType	= null;
			_mediaInfo.broadcasting = false;
			
			if(_camAndMic)
			{
				//Tracer.log(this, "stopMedia - STOP CAM AND MIC");
				_camAndMic.camera 		= null;
				_camAndMic.microphone 	= null;
			}
			
			if(_sendStream)
			{
				//Tracer.log(this, "stopMedia - _sendStream.close()");
				_sendStream.close();
				_sendStream.attachCamera(null);
				_sendStream.attachAudio(null);
				_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
		}
		
		private function publishMedia(type:String, order:String, backNotFrontCamera:Boolean = false):void
		{
			_mediaInfo.order							   = order;
			_mediaInfo.broadcasting	   					   = true;
			_mediaInfo.mediaType 	   					   = type;
			_mediaInfo.publisherFarID  					   = _localClientInfo.localClient.peerID;
			_mediaInfo.publisherGroupspecWithAuthorization = getMediaGroupSpec().groupspecWithoutAuthorizations(); //_localClientInfo.localClientGroupspecWithAuthorization;
			
			setupNetStream();
			//Tracer.log(this,"publishMedia - _localClientInfo: "+ _localClientInfo +" type: "+type+"  stream name: "+GetMediaInfo.getStreamName(_mediaInfo)+"  _groupConnection: "+_groupConnection+" _mediaInfo.publisherGroupspecWithAuthorization : "+_mediaInfo.publisherGroupspecWithAuthorization);
			
			//Tracer.log(this, "publishMedia - _camAndMic.broadcasterHasTwoCameras: "+_camAndMic.broadcasterHasTwoCameras);
			
			_mediaInfo.backNotFrontCamera 					= backNotFrontCamera;
			_mediaInfo.broadcasterUID						= _camAndMic.broadcasterUID;
			_mediaInfo.requesterUID							= _camAndMic.requesterUID;
			_mediaInfo.deviceType							= _camAndMic.deviceType;
			_mediaInfo.broadcasterHasTwoCameras				= _camAndMic.broadcasterHasTwoCameras;
			_mediaInfo.publisherStream 						= GetMediaInfo.getStreamName(_mediaInfo);
			setNetStreamClient();
			
			//THIS IS INCORRECT, NOT POSSIBLE TO STREAM DIRECTTLY, need to use appendBytes of NetStream 
			attachAudioAndVideo();
			//Tracer.log(this, "publishMedia - publisherStream: "+_mediaInfo.publisherStream);
			_sendStream.publish(_mediaInfo.publisherStream);
		}
		
		private function setupNetStream():void
		{
			//Tracer.log(this, "-----------------------------------------------------------------------------");
			//Tracer.log(this, "setupNetStream - gSpec: "+_localClientInfo.localClientGroupspecWithAuthorization);
			
			_sendStream = new NetStream(_groupConnection.groupNetConnection, _mediaInfo.publisherGroupspecWithAuthorization);
			_sendStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function setNetStreamClient():void
		{
			var sendStreamClient:Object = new Object();
			
			sendStreamClient.onPeerConnect = function(callerns:NetStream):Boolean
			{
				//_mediaInfo.publisherFarID = callerns.farID;
				//Tracer.log(this,"_sendStream.client.sendStreamClient.onPeerConnect "+callerns.farID);
				return true;
			}	
			
			_sendStream.client = sendStreamClient;
			_netStreamSignal.dispatch(_sendStream);
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
		
		public function broadcastMediaInfoChange(mediaInfo:MediaVO = null, toRequesterID:String = null):void
		{
			//Tracer.log(this, "broadcastMediaInfoChange - mediaType: "+mediaType);
			if(!mediaInfo)
			{
				mediaInfo = _mediaInfo;
				_mediaInfo.requesterUID = toRequesterID;
			}
			
			_mediaMessenger.sendMediaMessageToAll( (mediaInfo) ? mediaInfo : _mediaInfo );
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{  
			//Tracer.log( this, "onNetStatus - event.info: "+event.info.code.toString() );
			switch (event.info.code) 
			{
				case NetStatusCode.NETSTREAM_START:
					broadcastMediaInfoChange(_mediaInfo);
					break;
			}
		}
		
		protected function getMediaGroupSpec():GroupSpecifier
		{
			if(!_mediaGroupSpec)  
			{
				_mediaGroupSpec = _groupConnection.createMediaBroadcastNetGroup(_localClientInfo.groupName);
			}
			
			return _mediaGroupSpec;
		}
		
		public function disconnect():void
		{
			stopMedia();
		}
	}
}