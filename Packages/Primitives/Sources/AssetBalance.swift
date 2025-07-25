import Foundation
import BigInt

public enum AssetBalanceType: Sendable {
    case coin(available: BigInt, reserved: BigInt)
    case token(available: BigInt)
    case stake(staked: BigInt, pending: BigInt, rewards: BigInt, reserved: BigInt, locked: BigInt, frozen: BigInt)
    
    public var available: BigInt? {
        switch self {
        case .coin(let available, _): available
        case .token(let available): available
        case .stake: nil
        }
    }
}

public struct AssetBalanceChange: Sendable {
    public let assetId: AssetId
    public let type: AssetBalanceType
    public let isActive: Bool
    
    public init(
        assetId: AssetId, type:
        AssetBalanceType,
        isActive: Bool
    ) {
        self.assetId = assetId
        self.type = type
        self.isActive = isActive
    }
}

public struct AssetBalance: Codable, Sendable {
	public let assetId: AssetId
	public let balance: Balance
    public let isActive: Bool

	public init(
        assetId: AssetId,
        balance: Balance,
        isActive: Bool = true
    ) {
		self.assetId = assetId
		self.balance = balance
        self.isActive = isActive
	}
}

extension AssetBalance {
    public var coinChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.coin(available: balance.available, reserved: balance.reserved),
            isActive: isActive
        )
    }
    
    public var tokenChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.token(available: balance.available),
            isActive: isActive
        )
    }

    public var stakeChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.stake(
                staked: balance.staked,
                pending: balance.pending,
                rewards: balance.rewards,
                reserved: balance.reserved,
                locked: balance.locked,
                frozen: balance.frozen
            ),
            isActive: isActive
        )
    }
    
    public static func merge(assetIds: [AssetId], balances: [BigInt]) -> [AssetBalance] {
        return zip(assetIds, balances).map {
            AssetBalance(assetId: $0, balance: Balance(available: $1))
        }
    }
}

public struct WalletAssetBalance: Codable, Sendable {
    public let walletId: String
    public let balance: AssetBalance

    public init(
        walletId: String,
        balance: AssetBalance
    ) {
        self.walletId = walletId
        self.balance = balance
    }
}

public extension AssetBalance {
    static func make(
        for assetId: AssetId,
        balance: Balance = Balance(available: .zero)
    ) -> AssetBalance {
        return AssetBalance(
            assetId: assetId,
            balance: balance
        )
    }
}
