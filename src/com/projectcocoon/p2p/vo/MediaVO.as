package com.projectcocoon.p2p.vo
{
	[Bindable]
	public class MediaVO 
	{
		public var publishNotInterupt				   : Boolean;
		public var publisherFarID	  				   : String;
		public var publisherGroupspecWithAuthorization : String;
		public var publisherStream 					   : String;
		public var mediaType	   					   : String;
		public var broadcasting						   : Boolean;
		public var order							   : String;
		public var backNotFrontCamera		 		   : Boolean;
		public var requesterUID						   : String;
		public var broadcasterUID					   : String;
		public var deviceType						   : String;
		public var broadcasterHasTwoCameras			   : Boolean;
	}
}