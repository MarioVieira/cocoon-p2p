package com.projectcocoon.p2p.vo
{
	public class MediaVO 
	{
		public var publishNotInterupt	: Boolean;
		public var publisherFarID  		: String;
		public var publisherStream 		: String;
		public var mediaType	   		: String;
		public var client		   		: ClientVO;
		public var broadcasting			: Boolean;
		
		public function MediaVO(client:ClientVO)
		{
			this.client	= client;
		}
	}
}