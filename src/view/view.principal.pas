unit view.principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Actions,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, System.IoUtils,
  System.Permissions,
  FMX.DialogService, FMX.ScrollBox, FMX.Memo
{$IFDEF Android}
    , Androidapi.jni.Os,
  Androidapi.jni.Support,
  Androidapi.jni.GraphicsContentViewText,
  Androidapi.Helpers
{$ENDIF};

type
  TForm1 = class(TForm)
    Image1: TImage;
    btnCamera: TButton;
    ActionList1: TActionList;
    btnGaleria: TButton;
    TakePhotoFromCameraAction1: TTakePhotoFromCameraAction;
    TakePhotoFromLibraryAction1: TTakePhotoFromLibraryAction;
    Memo1: TMemo;
    Button1: TButton;
    procedure btnCameraClick(Sender: TObject);
    procedure btnGaleriaClick(Sender: TObject);
    procedure TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
    procedure TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
    procedure Button1Click(Sender: TObject);
  private
    procedure DisplayRationale(Sender: TObject;
      const APermissions: TArray<string>; const APostRationaleProc: TProc);
    procedure TakeCameraPermissionRequestResult(Sender: TObject;
      const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>);
    procedure TakeGaleriaPermissionRequestResult(Sender: TObject;
      const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>);

    procedure PermissionCamera;
    procedure PermissionGaleria;
    procedure ListarArquivos(Diretorio: string; Sub: Boolean);
    function TemAtributo(Attr, Val: Integer): Boolean;

  var
    FPermissionCamera, FPermissionReadExternalStorage,
      FPermissionWriteExternalStorage: string;

  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btnCameraClick(Sender: TObject);
begin
{$IF Defined(IOS)}
  // atenção
  TakePhotoFromCameraAction1.Editable := true;
  TakePhotoFromCameraAction1.Execute;
{$ENDIF}
{$IF Defined(ANDROID)}
  // atenção
  TakePhotoFromCameraAction1.Editable := false;
  PermissionCamera;
{$ENDIF}
end;

procedure TForm1.btnGaleriaClick(Sender: TObject);
begin
{$IF Defined(IOS)}
  // atenção
  TakePhotoFromLibraryAction1.Editable := true;
  TakePhotoFromLibraryAction1.Execute;
{$ENDIF}
{$IF Defined(ANDROID)}
  // atenção
  TakePhotoFromLibraryAction1.Editable := false;
  PermissionGaleria;
{$ENDIF}
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Add(TPath.GetSharedPicturesPath);
  ListarArquivos(TPath.GetSharedDownloadsPath, true);
  ListarArquivos(TPath.GetSharedDownloadsPath, true);
end;

procedure TForm1.TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap := Image;

end;

procedure TForm1.TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap := Image;

end;

{$REGION 'Permission Camera'}

procedure TForm1.PermissionCamera;
begin
{$IF Defined(ANDROID)}
  FPermissionCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
  FPermissionReadExternalStorage :=
    JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);
  FPermissionWriteExternalStorage :=
    JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);

  if ((TJContextCompat.JavaClass.checkSelfPermission(TAndroidHelper.Activity,
    TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE) <>
    TJPackageManager.JavaClass.PERMISSION_GRANTED) or
    (TJContextCompat.JavaClass.checkSelfPermission(TAndroidHelper.Activity,
    TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE) <>
    TJPackageManager.JavaClass.PERMISSION_GRANTED) or
    (TJContextCompat.JavaClass.checkSelfPermission(TAndroidHelper.Activity,
    TJManifest_permission.JavaClass.CAMERA) <>
    TJPackageManager.JavaClass.PERMISSION_GRANTED)) then
  begin
    PermissionsService.RequestPermissions([FPermissionReadExternalStorage,
      FPermissionWriteExternalStorage, FPermissionCamera],
      TakeCameraPermissionRequestResult, DisplayRationale);
  end
  else
    TakePhotoFromCameraAction1.Execute;
{$ENDIF}
end;

procedure TForm1.TakeCameraPermissionRequestResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
begin
  if (Length(AGrantResults) = 3) and
    (AGrantResults[0] = TPermissionStatus.Granted) and
    (AGrantResults[1] = TPermissionStatus.Granted) and
    (AGrantResults[2] = TPermissionStatus.Granted) then
    TakePhotoFromCameraAction1.Execute
  else
    TDialogService.ShowMessage
      ('Cannot take a photo because the required permissions are not all granted');
end;

{$ENDREGION}
{$REGION 'Permission Galeria'}

procedure TForm1.PermissionGaleria;
begin
{$IF Defined(ANDROID)}
  FPermissionReadExternalStorage :=
    JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);
  FPermissionWriteExternalStorage :=
    JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);

  if ((TJContextCompat.JavaClass.checkSelfPermission(TAndroidHelper.Activity,
    TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE) <>
    TJPackageManager.JavaClass.PERMISSION_GRANTED) or
    (TJContextCompat.JavaClass.checkSelfPermission(TAndroidHelper.Activity,
    TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE) <>
    TJPackageManager.JavaClass.PERMISSION_GRANTED)) then
  begin
    PermissionsService.RequestPermissions([FPermissionReadExternalStorage,
      FPermissionWriteExternalStorage, FPermissionCamera],
      TakeCameraPermissionRequestResult, DisplayRationale);
  end
  else
    TakePhotoFromLibraryAction1.Execute;
{$ENDIF}
end;

procedure TForm1.TakeGaleriaPermissionRequestResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
begin
  if (Length(AGrantResults) = 3) and
    (AGrantResults[0] = TPermissionStatus.Granted) and
    (AGrantResults[1] = TPermissionStatus.Granted) then
    TakePhotoFromLibraryAction1.Execute
  else
    TDialogService.ShowMessage
      ('Cannot take a photo because the required permissions are not all granted');
end;

{$ENDREGION}

procedure TForm1.DisplayRationale(Sender: TObject;
  const APermissions: TArray<string>; const APostRationaleProc: TProc);
var
  I: Integer;
  RationaleMsg: string;
begin
  for I := 0 to High(APermissions) do
  begin
    if APermissions[I] = FPermissionCamera then
      RationaleMsg := RationaleMsg +
        'The app needs to access the camera to take a photo' + SLineBreak +
        SLineBreak
    else if APermissions[I] = FPermissionReadExternalStorage then
      RationaleMsg := RationaleMsg +
        'The app needs to read a photo file from your device';
  end;

  // Show an explanation to the user *asynchronously* - don't block this thread waiting for the user's response!
  // After the user sees the explanation, invoke the post-rationale routine to request the permissions
  TDialogService.ShowMessage(RationaleMsg,
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc;
    end);
end;

procedure TForm1.ListarArquivos(Diretorio: string; Sub: Boolean);
var
  F: TSearchRec;
  Ret: Integer;
  TempNome: string;

  s: string;
  DirList: TStringDynArray;

begin

  DirList := TDirectory.GetFiles(Diretorio, '*');
  if Length(DirList) = 0 then
    Memo1.Lines.Add('No files found in ' + Diretorio)
  else // Files found. List them.
  begin
    for s in DirList do
      Memo1.Lines.Add(s);
  end;

  //
  // Ret := FindFirst(Diretorio + '\*.*', faAnyFile, F);
  // try
  // while Ret = 0 do
  // begin
  // if TemAtributo(F.Attr, faDirectory) then
  // begin
  // if (F.Name <> '.') And (F.Name <> '..') then
  // if Sub = True then
  // begin
  // TempNome := Diretorio + '\' + F.Name;
  // ListarArquivos(TempNome, True);
  // end;
  // end
  // else
  // begin
  // Memo1.Lines.Add(Diretorio + '\' + F.Name);
  // end;
  // Ret := FindNext(F);
  // end;
  // finally
  // begin
  // FindClose(F);
  // end;
  // end;
end;

function TForm1.TemAtributo(Attr, Val: Integer): Boolean;
begin
  Result := Attr and Val = Val;

end;

end.
