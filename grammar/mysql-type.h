/* 
 * Copyright (c) 2013, 2014, Oracle and/or its affiliates. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; version 2 of the
 * License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301  USA
 */

#ifndef MYSQL_TYPE_H_
#define MYSQL_TYPE_H_

// Describes the type of a given query.
enum MySQLQueryType
{
  QtUnknown,
  QtAmbiguous,

  // DDL
  QtAlterDatabase,
  QtAlterLogFileGroup,
  QtAlterFunction,
  QtAlterProcedure,
  QtAlterServer,
  QtAlterTable,
  QtAlterTableSpace,
  QtAlterEvent,
  QtAlterView,

  QtCreateTable,
  QtCreateIndex,
  QtCreateDatabase,
  QtCreateEvent,
  QtCreateView,
  QtCreateRoutine,    // All of procedure, function, UDF. Used for parse type.
  QtCreateProcedure,
  QtCreateFunction,
  QtCreateUdf,
  QtCreateTrigger,
  QtCreateLogFileGroup,
  QtCreateServer,
  QtCreateTableSpace,

  QtDropDatabase,
  QtDropEvent,
  QtDropFunction, // Includes UDF.
  QtDropProcedure,
  QtDropIndex,
  QtDropLogfileGroup,
  QtDropServer,
  QtDropTable,
  QtDropTablespace,
  QtDropTrigger,
  QtDropView,

  QtRenameTable,
  QtTruncateTable,

  // DML
  QtCall,
  QtDelete,
  QtDo,

  QtHandler, // Do we need Handler open/close etc.?

  QtInsert,
  QtLoadData,
  QtLoadXML,
  QtReplace,
  QtSelect,
  QtUpdate,

  QtPartition, // Cannot be used standalone.

  QtStartTransaction,
  QtBeginWork,
  QtCommit,
  QtRollbackWork,
  QtSetAutoCommit, // "set autocommit" is especially mentioned in transaction help, so identify this too.
  QtSetTransaction,

  QtSavepoint,
  QtReleaseSavepoint,
  QtRollbackSavepoint,

  QtLock,
  QtUnlock,

  QtXA,    // Do we need xa start, xa end etc.?

  QtPurge,
  QtChangeMaster,
  QtReset,
  QtResetMaster,
  QtResetSlave,
  QtStartSlave,
  QtStopSlave,
  QtLoadDataMaster,
  QtLoadTableMaster,

  QtPrepare,
  QtExecute,
  QtDeallocate,

  // Database administration
  QtAlterUser,
  QtCreateUser,
  QtDropUser,
  QtGrantProxy,
  QtGrant,
  QtRenameUser,
  QtRevokeProxy,
  QtRevoke,

  QtAnalyzeTable,
  QtCheckTable,
  QtChecksumTable,
  QtOptimizeTable,
  QtRepairTable,
  QtBackUpTable,
  QtRestoreTable,

  QtInstallPlugin,
  QtUninstallPlugin,

  QtSet,   // Any variable assignment.
  QtSetPassword,

  QtShow,
  QtShowAuthors,
  QtShowBinaryLogs,
  QtShowBinlogEvents,
  QtShowRelaylogEvents,
  QtShowCharset,
  QtShowCollation,
  QtShowColumns,
  QtShowContributors,
  QtShowCreateDatabase,
  QtShowCreateEvent,
  QtShowCreateFunction,
  QtShowCreateProcedure,
  QtShowCreateTable,
  QtShowCreateTrigger,
  QtShowCreateView,
  QtShowDatabases,
  QtShowEngineStatus,
  QtShowStorageEngines,
  QtShowErrors,
  QtShowEvents,
  QtShowFunctionCode,
  QtShowFunctionStatus,
  QtShowGrants,
  QtShowIndexes, // Index, Indexes, Keys
  QtShowInnoDBStatus,
  QtShowMasterStatus,
  QtShowOpenTables,
  QtShowPlugins,
  QtShowProcedureStatus,
  QtShowProcedureCode,
  QtShowPrivileges,
  QtShowProcessList,
  QtShowProfile,
  QtShowProfiles,
  QtShowSlaveHosts,
  QtShowSlaveStatus,
  QtShowStatus,
  QtShowVariables,
  QtShowTableStatus,
  QtShowTables,
  QtShowTriggers,
  QtShowWarnings,

  QtCacheIndex,
  QtFlush,
  QtKill,   // Connection, Query
  QtLoadIndex,

  QtExplainTable,
  QtExplainStatement,
  QtHelp,
  QtUse,

  QtSentinel

};
#endif
