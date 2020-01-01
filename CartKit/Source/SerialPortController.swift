import ORSSerial

/**
 A `SerialPortController` instance can:
    - `open` and `close` a serial port; and
    - `send` arbitruary data to said serial port; and
    - execute `SerialPacketOperations` submitted as operations.
 */
public protocol SerialPortController {
    ///
    var isOpen: Bool { get }

    /**
     */
    func openReader(delegate: ORSSerialPortDelegate?)
    
    /**
     */
    @discardableResult
    func closePort() -> Bool
    
    /**
     Notifies the receiver that the underlying serial port has been closed.
     
     Use this function to give the controller an opportunity to a prepare a full
     shutdown of its own state, such as _signaling_ locks.
     */
    func serialPortWasClosed()
}

extension SerialPortController {
    func request<Number>(totalBytes unitCount: Number,
                   packetSize maxPacketLength: UInt,
                              timeoutInterval: TimeInterval = -1.0,
                                prepare block: @escaping ((Self) -> ()),
                              progress update: @escaping (Self, _ with: Progress) -> (),
                            responseEvaluator: @escaping ORSSerialPacketEvaluator,
                                       result: @escaping (Result<Data, SerialPortRequestError>) -> ()) -> SerialPortRequest<Self> where Number: FixedWidthInteger
    {
        SerialPortRequest(     controller: self,
                                unitCount: Int64(unitCount),
                          timeoutInterval: timeoutInterval,
                          maxPacketLength: maxPacketLength,
                        responseEvaluator: { data in responseEvaluator(data!) },
                                  perform: { progress in
                                    if progress.completedUnitCount == 0 {
                                        block(self)
                                    }
                                    else {
                                        update(self, progress)
                                    }}) { result($0) }
    }
}
