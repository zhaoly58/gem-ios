/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct SolanaAccount<T: Codable & Sendable>: Codable, Sendable {
	public let lamports: UInt64
	public let space: UInt64
	public let owner: String
	public let data: T

	public init(lamports: UInt64, space: UInt64, owner: String, data: T) {
		self.lamports = lamports
		self.space = space
		self.owner = owner
		self.data = data
	}
}

public struct SolanaAccountParsed<T: Codable & Sendable>: Codable, Sendable {
	public let parsed: T

	public init(parsed: T) {
		self.parsed = parsed
	}
}

public struct SolanaAccountParsedInfo<T: Codable & Sendable>: Codable, Sendable {
	public let info: T

	public init(info: T) {
		self.info = info
	}
}

public struct SolanaRentExemptReserve: Codable, Sendable {
	public let rentExemptReserve: String

	public init(rentExemptReserve: String) {
		self.rentExemptReserve = rentExemptReserve
	}
}

public struct SolanaStakeDelegation: Codable, Sendable {
	public let voter: String
	public let stake: String
	public let activationEpoch: String
	public let deactivationEpoch: String

	public init(voter: String, stake: String, activationEpoch: String, deactivationEpoch: String) {
		self.voter = voter
		self.stake = stake
		self.activationEpoch = activationEpoch
		self.deactivationEpoch = deactivationEpoch
	}
}

public struct SolanaStake: Codable, Sendable {
	public let delegation: SolanaStakeDelegation

	public init(delegation: SolanaStakeDelegation) {
		self.delegation = delegation
	}
}

public struct SolanaStakeAccount: Codable, Sendable {
	public let account: SolanaAccount<SolanaAccountParsed<SolanaAccountParsedInfo<SolanaStakeInfo>>>
	public let pubkey: String

	public init(account: SolanaAccount<SolanaAccountParsed<SolanaAccountParsedInfo<SolanaStakeInfo>>>, pubkey: String) {
		self.account = account
		self.pubkey = pubkey
	}
}

public struct SolanaStakeInfo: Codable, Sendable {
	public let stake: SolanaStake
	public let meta: SolanaRentExemptReserve

	public init(stake: SolanaStake, meta: SolanaRentExemptReserve) {
		self.stake = stake
		self.meta = meta
	}
}

public struct SolanaTokenAccount: Codable, Sendable {
	public let account: SolanaAccount<SolanaAccountParsed<SolanaAccountParsedInfo<SolanaTokenInfo>>>
	public let pubkey: String

	public init(account: SolanaAccount<SolanaAccountParsed<SolanaAccountParsedInfo<SolanaTokenInfo>>>, pubkey: String) {
		self.account = account
		self.pubkey = pubkey
	}
}

public struct SolanaTokenAccountPubkey: Codable, Sendable {
	public let pubkey: String

	public init(pubkey: String) {
		self.pubkey = pubkey
	}
}

public struct SolanaTokenAmount: Codable, Sendable {
	public let amount: String

	public init(amount: String) {
		self.amount = amount
	}
}

public struct SolanaTokenInfo: Codable, Sendable {
	public let tokenAmount: SolanaTokenAmount

	public init(tokenAmount: SolanaTokenAmount) {
		self.tokenAmount = tokenAmount
	}
}
