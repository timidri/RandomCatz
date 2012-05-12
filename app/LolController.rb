class LolController < UIViewController

  def loadView
    self.view = UIImageView.alloc.initWithFrame(UIScreen.mainScreen.applicationFrame)
    view.userInteractionEnabled = true
    view.contentMode = UIViewContentModeScaleAspectFit
    @activityIndicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhiteLarge)
    @activityIndicator.center = self.view.center
    view.addSubview(@activityIndicator)
    @lolURL = NSURL.URLWithString("http://lolcats.icanhascheezburger.com/?random")
    @receivedData = NSMutableData.new
    recognizer = UITapGestureRecognizer.alloc.initWithTarget(self, action:'loadNextLol')
    view.addGestureRecognizer(recognizer)
  end

  def viewDidLoad
    # puts("didload: view center: " + view.center.x.description + ":" + view.center.y.description)
    loadNextLol
  end

  def loadNextLol
    puts("loadNextLol")
    @activityIndicator.startAnimating
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
    request = NSURLRequest.requestWithURL(@lolURL)
    @lolConnection = NSURLConnection.connectionWithRequest(request, delegate:self)
  end

  def connection(connection, didReceiveResponse:response)
    @receivedData.setLength(0)
    #puts("didReceiveResponse: " + response.allHeaderFields.description + " status:" + response.statusCode.description)
  end

  def connection(connection, didReceiveData:data)
    @receivedData.appendData(data)
    #puts("didReceiveData: ")
  end

  def connection(connection, didFailWithError:error)
    puts("Connection failed! Error - " + error.localizedDescription + error.userInfo.objectForKey(NSURLErrorFailingURLStringErrorKey))
  end

  def connectionDidFinishLoading(connection)
    puts("Succeeded! Received bytes of data: "  + @receivedData.length.description);
    page = NSString.alloc.initWithBytes(@receivedData.bytes, length:@receivedData.length, encoding:NSUTF8StringEncoding)
    lolUrl = scrapeLolImage(page)
    if lolUrl.nil?
      puts("Loading failed, loading next lol...")
      loadNextLol
    else
      self.view.image = UIImage.imageWithData(NSData.dataWithContentsOfURL(NSURL.URLWithString(lolUrl)))
      @activityIndicator.stopAnimating
      UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    end
  end

  def scrapeLolImage(page)
    scanner = NSScanner.scannerWithString(page)
    if ! scanner.scanUpToString("<img class='event-item-lol-image' src='", intoString:nil)
      puts("string not found, printing page...")
      puts("==== page start ====\n" + page + "\n==== page end =====\n")
      return nil
    end
    scanner.scanString("<img class='event-item-lol-image' src='", intoString:nil)
    scannedUrlPtr = Pointer.new(:object)
    if ! scanner.scanUpToString("'", intoString:scannedUrlPtr)
      puts("end of string not found, printing page...")
      puts("==== page start ====\n" + page + "\n==== page end =====\n")
      return nil
    end
    lolUrl = scannedUrlPtr[0]
    puts("lolUrl scraped = " + lolUrl)
    lolUrl
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
end