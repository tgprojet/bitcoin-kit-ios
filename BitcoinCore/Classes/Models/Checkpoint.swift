import UIExtensions
struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}

public struct Checkpoint {
    public let block: Block
    public let additionalBlocks: [Block]
    public static let CheckpointConstants = ["BitcoinKit_MainNet-last":"0000a020c53598bd71e3a1277ffe6fe664ad25fcbdd799698728050000000000000000000d4ae8ee20c30b1b7abb8b5b299771ce78b376c7f976ad5b2c2c6b607e4078a79297d962042a0a170ebda527c0610b001a441fa6520761f4a35768dbdbffa3acadf84870ae150a000000000000000000",
                                             "BitcoinKit_MainNet-bip44":"02000000ba3f2b4208ec0495b2e3743465cae2b44d8f1c778b44cf6b0000000000000000d287e52e8045c060c1cee47d1cc7559c7b8ab8db580539fb55fc579a998ea14efe0e50538c9d001926c0c180a08504003f72e59e0db5b38e5210369dc2fb4831ab1e81f3b5dbec3d0000000000000000"]
    public init(block: Block, additionalBlocks: [Block]) {
        self.block = block
        self.additionalBlocks = additionalBlocks
    }

    public init(podBundle: Bundle, bundleName: String, filename: String) throws {
        //guard let checkpointsBundleURL = podBundle.url(forResource: bundleName, withExtension: "bundle") else {
        //    throw RuntimeError("Some Error" + String(describing:podBundle) + bundleName + filename)
            //throw ParseError.invalidBundleUrl
       // }
      //  guard let checkpointsBundle = Bundle(url: checkpointsBundleURL) else {
        //    throw ParseError.invalidBundle
       // }
       // guard let fileURL = checkpointsBundle.url(forResource: filename, withExtension: "checkpoint") else {
        //    throw RuntimeError("Some Error" + String(describing:podBundle) + bundleName + filename)
           // throw ParseError.invalidFileUrl
        //}
        let bundleKey = bundleName + "_" + filename
        let string = Checkpoint.CheckpointConstants[bundleKey]!
 
        //let string = try String(contentsOf: fileURL, encoding: .utf8)
        var lines = string.components(separatedBy: .newlines).filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            throw ParseError.invalidFile
        }

        block = try Checkpoint.readBlock(string: lines.removeFirst())
        additionalBlocks = try lines.map { try Checkpoint.readBlock(string: $0) }
    }

    private static func readBlock(string: String) throws -> Block {
        guard let data = Data(hex: string) else {
            throw ParseError.invalidFile
        }

        let byteStream = ByteStream(data)

        let version = Int(byteStream.read(Int32.self))
        let previousBlockHeaderHash = byteStream.read(Data.self, count: 32)
        let merkleRoot = byteStream.read(Data.self, count: 32)
        let timestamp = Int(byteStream.read(UInt32.self))
        let bits = Int(byteStream.read(UInt32.self))
        let nonce = Int(byteStream.read(UInt32.self))
        let height = Int(byteStream.read(UInt32.self))
        let headerHash = byteStream.read(Data.self, count: 32)

        let header = BlockHeader(
                version: version,
                headerHash: headerHash,
                previousBlockHeaderHash: previousBlockHeaderHash,
                merkleRoot: merkleRoot,
                timestamp: timestamp,
                bits: bits,
                nonce: nonce
        )

        return Block(withHeader: header, height: height)
    }

}

public extension Checkpoint {

    enum ParseError: Error {
        case invalidBundleUrl
        case invalidBundle
        case invalidFileUrl
        case invalidFile
    }

}
