{
Copyright (C) 2023 Matteo Salvi

Website: http://www.salvadorsoftware.com/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

unit Kernel.Logger;

{$MODE DelphiUnicode}

interface

uses
  SysUtils, mormot.core.log, mormot.core.base, LazLogger;

type

  { TLogger }

  TLogger = class
  public
    class procedure Info(const AText: string; AParams: array of const);
    class procedure Debug(const AText: string; AParams: array of const);
    class procedure Error(const AText: string; AParams: array of const);
    class procedure Exception(E: SysUtils.Exception; const AText: string = '');
    class procedure InfoEnter(const AText: string; AParams: array of const);
    class procedure InfoExit(const AText: string; AParams: array of const);
  end;

var
  FLOG_INFO: PLazLoggerLogGroup;
  FLOG_ERROR: PLazLoggerLogGroup;
  FLOG_DEBUG: PLazLoggerLogGroup;

implementation

{ TLogger }

class procedure TLogger.Debug(const AText: string; AParams: array of const);
begin
  DebugLn(['[DEBUG] ', Format(AText, AParams)]);
end;

class procedure TLogger.Error(const AText: string; AParams: array of const);
begin
  DebugLn(['[ERROR] ', Format(AText, AParams)]);
end;

class procedure TLogger.Info(const AText: string; AParams: array of const);
begin
  DebugLn(['[INFO] ', Format(AText, AParams)]);
end;

class procedure TLogger.Exception(E: SysUtils.Exception; const AText: string);
begin
  DebugLn(['[EXCEPTION] ', E.Message, E]);
end;

class procedure TLogger.InfoEnter(const AText: string; AParams: array of const);
begin
  DebugLnEnter(['[INFO] ', Format(AText, AParams)]);
end;

class procedure TLogger.InfoExit(const AText: string; AParams: array of const);
begin
  DebugLnExit(['[INFO] ', Format(AText, AParams)]);
end;

initialization
  FLOG_INFO := DebugLogger.FindOrRegisterLogGroup('LOG_INFO', True);
  FLOG_ERROR := DebugLogger.FindOrRegisterLogGroup('LOG_ERROR', True);
  FLOG_DEBUG := DebugLogger.FindOrRegisterLogGroup('LOG_DEBUG', False);

end.
