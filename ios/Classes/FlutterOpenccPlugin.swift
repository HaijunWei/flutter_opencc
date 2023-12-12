import Flutter
import UIKit

public class FlutterOpenccPlugin: NSObject, FlutterPlugin {
  override init() {
    super.init()
    opencc_error()
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
  }
}
