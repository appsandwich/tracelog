///
///  TraceLog.swift
///
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 11/1/16.
///
import Swift
import Foundation

// MARK: Configuration

/// Initializes TraceLog with an optional mode, array of Writers and the Environment.
///
/// This call is optional but in order to read from the environment on start up,
/// this method must be called.
///
/// - Parameters:
///     - mode:        The `ConcurrencyMode` to run all `Writer`s in. Async is the default.
///     - writers:     An Array of objects that implement the `Writer` protocol used to process messages that are logged. Note the writers are called in the order they are in this array.
///     - environment: Either a `Dictionary<String, String>` or an `Environment` object that contains the key/value pairs of configuration variables for TraceLog.
///
/// - Example:
///
/// Start TraceLog in the default mode, with default writers.
/// ```
///     TraceLog.configure()
/// ```
///
/// Start TraceLog the with default writer in `.direct` mode.
/// ```
///     TraceLog.configure(mode: .direct)
/// ```
///
/// Start TraceLog in the default mode, replacing the default writer with `MyWriter` reading the environment for log level settings.
/// ```
///     TraceLog.configure(writers: [MyWriter()])
/// ```
///
/// Start TraceLog in the default mode, replacing the default writer with `MyWriter` and setting log levels programmatically.
/// ```
///     TraceLog.configure(writers: [MyWriter()], environment: ["LOG_ALL": "TRACE4",
///                                                              "LOG_PREFIX_NS" : "ERROR",
///                                                              "LOG_TAG_TraceLog" : "TRACE4"])
/// ```
///
public func configure(mode: ConcurrencyMode = .default, writers: [Writer] = [ConsoleWriter()], environment: Environment = Environment()) {
    #if !TRACELOG_DISABLED
        Logger.configure(writers: writers.map( { mode.writerMode(for: $0) } ), environment: environment)
    #endif
}

/// Initializes TraceLog with an optional array of Writers specifying their ConcurrencyMode and the Environment.
///
/// - Parameters:
///     - writers:     An Array of `Writer`s wrapped in a `WriterConcurrencyMode`.
///     - environment: Either a `Dictionary<String, String>` or an `Environment` object that contains the key/value pairs of configuration variables for TraceLog.
///
/// - Example:
///
/// Start TraceLog replacing the default writer with `MyWriter` running in `.direct` mode, `MyHTTPWriter`
/// in `.async` mode, and reading the environment for log level settings.
/// ```
///     TraceLog.configure(writers: [.direct(MyWriter()), .async(MyHTTPWriter())])
/// ```
///
/// Start TraceLog replacing the default writer with `MyWriter` running in `.async` mode and  setting log
/// levels programmatically.
/// ```
///     TraceLog.configure(writers: [.async(MyWriter())], environment: ["LOG_ALL": "TRACE4",
///                                                                                  "LOG_PREFIX_NS" : "ERROR",
///                                                                                  "LOG_TAG_TraceLog" : "TRACE4"])
/// ```
///
public func configure(writers: [WriterConcurrencyMode], environment: Environment = Environment()) {
    #if !TRACELOG_DISABLED
        Logger.configure(writers: writers, environment: environment)
    #endif
}

// MARK: Logging

/// Logs a message with `LogLevel.error` to the log `Writer`s.
///
/// - Parameters:
///     - tag:     A String to use as a tag to group this call to other calls related to it. If not passed or nil, the file name is used as a tag.
///     - message: An closure or trailing closure that evaluates to the String message to log.
///
public func logError(_ tag: String? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line, message: @escaping () -> String) {
    #if !TRACELOG_DISABLED
        let derivedTag = derivedTagIfNil(file: file, tag: tag)

        Logger.logPrimitive(level: LogLevel.error, tag: derivedTag, file: file, function: function, line: line, message: message)
    #endif
}

/// Logs a message with `LogLevel.warning` to the log `Writer`s.
///
/// - Parameters:
///     - tag:     A String to use as a tag to group this call to other calls related to it. If not passed or nil, the file name is used as a tag.
///     - message: An closure or trailing closure that evaluates to the String message to log.
///
public func logWarning(_ tag: String? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line, message:  @escaping () -> String) {
    #if !TRACELOG_DISABLED
        let derivedTag = derivedTagIfNil(file: file, tag: tag)

        Logger.logPrimitive(level: LogLevel.warning, tag: derivedTag, file: file, function: function, line: line, message: message)
    #endif
}

/// Logs a message with `LogLevel.info` to the log `Writer`s.
///
/// - Parameters:
///     - tag:     A String to use as a tag to group this call to other calls related to it. If not passed or nil, the file name is used as a tag.
///     - message: An closure or trailing closure that evaluates to the String message to log.
///
public func logInfo(_ tag: String? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line, message:  @escaping () -> String) {
    #if !TRACELOG_DISABLED
        let derivedTag = derivedTagIfNil(file: file, tag: tag)

        Logger.logPrimitive(level: LogLevel.info, tag: derivedTag, file: file, function: function, line: line, message: message)
    #endif
}

/// Logs a message with `LogLevel`.trace to the log `Writer`s.
///
/// - Parameters:
///     - tag:     A String to use as a tag to group this call to other calls related to it. If not passed or nil, the file name is used as a tag.
///     - level    An integer representing the trace LogLevel (i.e. 1, 2, 3, and 4.) If no value is passed, the default trace level is 1.
///     - message: An closure or trailing closure that evaluates to the String message to log.
///
public func logTrace(_ tag: String? = nil, level: Int = 1, _ file: String = #file, _ function: String = #function, _ line: Int = #line, message: @escaping () -> String) {
    #if !TRACELOG_DISABLED
        assert(LogLevel.validTraceLevels.contains(level), "Invalid trace level, levels are in the range of \(LogLevel.validTraceLevels)")

        let derivedTag = derivedTagIfNil(file: file, tag: tag)

        Logger.logPrimitive(level: LogLevel(rawValue: LogLevel.trace1.rawValue + level - 1)!, tag: derivedTag, file: file, function: function, line: line, message: message)    // swiftlint:disable:this force_unwrapping
    #endif
}

/// Logs a message with `LogLevel`.trace to the log `Writer`s.
///
/// - Parameters:
///     - level    An integer representing the trace LogLevel (i.e. 1, 2, 3, and 4.)
///     - message: An closure or trailing closure that evaluates to the String message to log.
///
public func logTrace(_ level: Int, _ file: String = #file, _ function: String = #function, _ line: Int = #line, message: @escaping () -> String) {
    #if !TRACELOG_DISABLED
        assert(LogLevel.validTraceLevels.contains(level), "Trace levels are in the range of \(LogLevel.validTraceLevels)")

        let derivedTag = derivedTagIfNil(file: file, tag: nil)

        Logger.logPrimitive(level: LogLevel(rawValue: LogLevel.trace1.rawValue + level - 1)!, tag: derivedTag, file: file, function: function, line: line, message: message) // swiftlint:disable:this force_unwrapping
    #endif
}

// MARK: Internal & private functions & Extensions.

@inline(__always)
private func derivedTagIfNil(file: String, tag: String?) -> String {
    if let unwrappedTag = tag {
       return unwrappedTag
    } else {
        return URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
    }
}
