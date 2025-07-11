/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct AlgorandTransactionBroadcast: Codable, Sendable {
	public let txId: String?
	public let message: String?

	public init(txId: String?, message: String?) {
		self.txId = txId
		self.message = message
	}
}

public struct AlgorandTransactionParams: Codable, Sendable {
	public let min_fee: UInt64
	public let genesis_id: String
	public let genesis_hash: String
	public let last_round: UInt64

	enum CodingKeys: String, CodingKey, Codable {
		case min_fee = "min-fee",
			genesis_id = "genesis-id",
			genesis_hash = "genesis-hash",
			last_round = "last-round"
	}

	public init(min_fee: UInt64, genesis_id: String, genesis_hash: String, last_round: UInt64) {
		self.min_fee = min_fee
		self.genesis_id = genesis_id
		self.genesis_hash = genesis_hash
		self.last_round = last_round
	}
}

public struct AlgorandTransactionStatus: Codable, Sendable {
	public let confirmed_round: UInt64

	enum CodingKeys: String, CodingKey, Codable {
		case confirmed_round = "confirmed-round"
	}

	public init(confirmed_round: UInt64) {
		self.confirmed_round = confirmed_round
	}
}
