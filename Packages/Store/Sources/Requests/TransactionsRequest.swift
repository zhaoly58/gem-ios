// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionsRequest: ValueObservationQueryable {
    public static var defaultValue: [TransactionExtended] { [] }

    private let walletId: String
    private let type: TransactionsRequestType
    private let limit: Int

    public var filters: [TransactionsRequestFilter] = []

    public init(
        walletId: String,
        type: TransactionsRequestType,
        filters: [TransactionsRequestFilter] = [],
        limit: Int = 50
    ) {
        self.walletId = walletId
        self.type = type
        self.filters = filters
        self.limit = limit
    }

    public func fetch(_ db: Database) throws -> [TransactionExtended] {
        try Self.fetch(db, type: type, filters: filters, walletId: walletId, limit: limit)
    }

    public static func fetch(
        _ db: Database,
        type: TransactionsRequestType,
        filters: [TransactionsRequestFilter],
        walletId: String,
        limit: Int
    ) throws -> [TransactionExtended] {
        let states = states(type: type)
        let types = types(type: type)
        var request = TransactionRecord
            .filter(TransactionRecord.Columns.walletId == walletId)
            .filter(states.contains(TransactionRecord.Columns.state))
            .filter(types.contains(TransactionRecord.Columns.type))
            .including(required: TransactionRecord.asset)
            .including(required: TransactionRecord.feeAsset)
            .including(optional: TransactionRecord.price)
            .including(optional: TransactionRecord.feePrice)
            .including(all: TransactionRecord.assets)
            .including(all: TransactionRecord.prices)
            .including(optional: TransactionRecord.fromAddress)
            .including(optional: TransactionRecord.toAddress)
            .order(TransactionRecord.Columns.date.desc)
            .distinct()
            .limit(limit)

        switch type {
        case .asset(let assetId):
            request = request.joining(required: TransactionRecord.assetsAssociation.filter(TransactionAssetAssociationRecord.Columns.assetId == assetId.identifier))
        case .assetsTransactionType(let assetIds, _, _):
            if !assetIds.isEmpty {
                request = request.joining(required: TransactionRecord.assetsAssociation.filter(assetIds.map { $0.identifier }.contains(TransactionAssetAssociationRecord.Columns.assetId)))
            }
        case .transaction(let id):
            request = request.filter(TransactionRecord.Columns.transactionId == id)
        case .all, .pending:
            break
        }

        filters.forEach {
            request = Self.applyFilter(request: request, $0)
        }

        return try request.asRequest(of: TransactionInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToTransactionExtended() }
    }
}

// MARK: - Private

extension TransactionsRequest {
    static func applyFilter(request: QueryInterfaceRequest<TransactionRecord>, _ filter: TransactionsRequestFilter) -> QueryInterfaceRequest<TransactionRecord> {
        switch filter {
        case .chains(let chains):
            guard !chains.isEmpty else { return request }
            return request.filter(chains.contains(TransactionRecord.Columns.chain))
        case .types(let types):
            guard !types.isEmpty else { return request }
            return request.filter(types.contains(TransactionRecord.Columns.type))
        }
    }

    private static func states(type: TransactionsRequestType) -> [String] {
        switch type {
        case .pending:
            [TransactionState.pending.rawValue]
        case .all, .asset, .transaction:
            TransactionState.allCases.map { $0.rawValue }
        case .assetsTransactionType(_, _, let states):
            states.map { $0.rawValue }
        }
    }

    private static func types(type: TransactionsRequestType) -> [String] {
        switch type {
        case .assetsTransactionType(_, let type, _):
            [type.rawValue]
        case .pending, .all, .asset, .transaction:
            TransactionType.allCases.map { $0.rawValue }
        }
    }
}

extension TransactionsRequest: Equatable {}
