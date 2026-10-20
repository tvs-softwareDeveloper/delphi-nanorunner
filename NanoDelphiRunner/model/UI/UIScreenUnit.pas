unit UIScreenUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IniFiles,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl,
  FMX.Objects, FMX.Layouts, InputStateUnit,
  FMX.Platform.Win, FMX.Edit, FMX.ListBox, System.Math, ErrorHandlerUnit;

type
  THomeScreen = class
  private
    tbiParent: TTabItem;

    rectBackground: TRectangle;
    d_card: TRectangle;

    lblPlayerName: TLabel;
    lblSessions: TLabel;

    edtPlayerName: TEdit;
    chkMultiplayer: TCheckBox;

    btnThemeJapanese: TButton;
    d_btnThemeMoonlanding: TButton;

    d_lstSession: TListBox;

  public
    constructor Create(AParent: TTabItem);
    destructor Destroy; override;

    procedure Build;
    procedure Resize;

    property Card: TRectangle read d_card;
    property PlayerNameLabel: TLabel read lblPlayerName;
    property SessionsLabel: TLabel read lblSessions;
    property PlayerNameEdit: TEdit read edtPlayerName;
    property MultiplayerCheckBox: TCheckBox read chkMultiplayer;
    property ThemeJapaneseButton: TButton read btnThemeJapanese;
    property ThemeMoonlandingButton: TButton read d_btnThemeMoonlanding;
    property SessionList: TListBox read d_lstSession;
  end;

  TLobbyScreen = class
  private
    tbiParent: TTabItem;

    rectBackground: TRectangle;
    rectCard: TRectangle;

    lblLobbyTitle: TLabel;
    lblLobbyPlayers: TLabel;
    lstLobbyPlayer: TListBox;
    btnBackToHome: TButton;

  public
    constructor Create(AParent: TTabItem);
    destructor Destroy; override;

    procedure Build;
    procedure Resize;

    property Card: TRectangle read rectCard;
    property LobbyTitleLabel: TLabel read lblLobbyTitle;
    property LobbyPlayersLabel: TLabel read lblLobbyPlayers;
    property LobbyPlayerList: TListBox read lstLobbyPlayer;
    property BackToHomeButton: TButton read btnBackToHome;
  end;

implementation

constructor THomeScreen.Create(AParent: TTabItem);
begin
  inherited Create;
  tbiParent := AParent;
end;

destructor THomeScreen.Destroy;
begin
  inherited;
end;

//home build
procedure THomeScreen.Build;
var
  TitleLabel: TLabel;
  SubTitleLabel: TLabel;
begin
  rectBackground := TRectangle.Create(tbiParent);
  rectBackground.Parent := tbiParent;
  rectBackground.Align := TAlignLayout.Client;
  rectBackground.Fill.Color := $FF11351F;
  rectBackground.Stroke.Kind := TBrushKind.None;
  rectBackground.HitTest := False;

  d_card := TRectangle.Create(tbiParent);
  d_card.Parent := tbiParent;
  d_card.Align := TAlignLayout.Center;
  d_card.Width := 520;
  d_card.Height := 560;
  d_card.XRadius := 28;
  d_card.YRadius := 28;
  d_card.Fill.Color := $EE1F5E32;
  d_card.Stroke.Color := $FFFFD166;
  d_card.Stroke.Thickness := 3;
  d_card.HitTest := False;

  TitleLabel := TLabel.Create(d_card);
  TitleLabel.Parent := d_card;
  TitleLabel.Text := 'Nano Banana Runner';
  TitleLabel.Position.X := 60;
  TitleLabel.Position.Y := 58;
  TitleLabel.Width := 430;
  TitleLabel.Height := 42;
  TitleLabel.StyledSettings := [];
  TitleLabel.TextSettings.Font.Size := 30;
  TitleLabel.TextSettings.Font.Style := [TFontStyle.fsBold];
  TitleLabel.TextSettings.FontColor := $FFFFD166;

  SubTitleLabel := TLabel.Create(d_card);
  SubTitleLabel.Parent := d_card;
  SubTitleLabel.Text := 'Kies je stijl, vul je naam in en start je avontuur';
  SubTitleLabel.Position.X := 62;
  SubTitleLabel.Position.Y := 102;
  SubTitleLabel.Width := 430;
  SubTitleLabel.Height := 28;
  SubTitleLabel.StyledSettings := [];
  SubTitleLabel.TextSettings.Font.Size := 15;
  SubTitleLabel.TextSettings.FontColor := $FFE9F5DB;

  lblPlayerName := TLabel.Create(d_card);
  lblPlayerName.Parent := d_card;
  lblPlayerName.Text := 'Spelernaam';
  lblPlayerName.Position.X := 62;
  lblPlayerName.Position.Y := 152;
  lblPlayerName.Width := 180;
  lblPlayerName.Height := 24;
  lblPlayerName.StyledSettings := [];
  lblPlayerName.TextSettings.Font.Size := 15;
  lblPlayerName.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblPlayerName.TextSettings.FontColor := $FFFFF3B0;

  edtPlayerName := TEdit.Create(d_card);
  edtPlayerName.Parent := d_card;
  edtPlayerName.Position.X := 62;
  edtPlayerName.Position.Y := 180;
  edtPlayerName.Width := 300;
  edtPlayerName.Height := 42;
  edtPlayerName.TextPrompt := 'Vul je naam in';

  chkMultiplayer := TCheckBox.Create(d_card);
  chkMultiplayer.Parent := d_card;
  chkMultiplayer.Text := 'multiplayer';
  chkMultiplayer.Position.X := 62;
  chkMultiplayer.Position.Y := 238;
  chkMultiplayer.Width := 180;
  chkMultiplayer.Height := 34;
  chkMultiplayer.StyledSettings := [];
  chkMultiplayer.TextSettings.Font.Size := 16;
  chkMultiplayer.TextSettings.FontColor := $FFFFFFFF;

  btnThemeJapanese := TButton.Create(d_card);
  btnThemeJapanese.Parent := d_card;
  btnThemeJapanese.Text := 'mythic japanese';
  btnThemeJapanese.Position.X := 62;
  btnThemeJapanese.Position.Y := 296;
  btnThemeJapanese.Width := 190;
  btnThemeJapanese.Height := 44;
  btnThemeJapanese.StyledSettings := [];
  btnThemeJapanese.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnThemeJapanese.TextSettings.FontColor := $FF0B2B18;

  d_btnThemeMoonlanding := TButton.Create(d_card);
  d_btnThemeMoonlanding.Parent := d_card;
  d_btnThemeMoonlanding.Text := 'fake moonlanding';
  d_btnThemeMoonlanding.Position.X := 270;
  d_btnThemeMoonlanding.Position.Y := 296;
  d_btnThemeMoonlanding.Width := 190;
  d_btnThemeMoonlanding.Height := 44;
  d_btnThemeMoonlanding.StyledSettings := [];
  d_btnThemeMoonlanding.TextSettings.Font.Style := [TFontStyle.fsBold];
  d_btnThemeMoonlanding.TextSettings.FontColor := $FF0B2B18;

  lblSessions := TLabel.Create(d_card);
  lblSessions.Parent := d_card;
  lblSessions.Text := 'Open game sessies';
  lblSessions.Position.X := 62;
  lblSessions.Position.Y := 372;
  lblSessions.Width := 250;
  lblSessions.Height := 28;
  lblSessions.StyledSettings := [];
  lblSessions.TextSettings.Font.Size := 17;
  lblSessions.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblSessions.TextSettings.FontColor := $FFFFD166;

  d_lstSession := TListBox.Create(d_card);
  d_lstSession.Parent := d_card;
  d_lstSession.Position.X := 62;
  d_lstSession.Position.Y := 408;
  d_lstSession.Width := 398;
  d_lstSession.Height := 146;
end;

//home resize
procedure THomeScreen.Resize;
var
  Padding: Single;
  ContentW: Single;
  ThemeGap: Single;
  ThemeButtonW: Single;
begin
  if not Assigned(d_card) then
    Exit;

  Padding := 32;
  ContentW := d_card.Width - Padding * 2;

  lblPlayerName.Position.X := Padding;
  lblPlayerName.Width := ContentW;

  edtPlayerName.Position.X := Padding;
  edtPlayerName.Width := ContentW;

  chkMultiplayer.Position.X := Padding;
  chkMultiplayer.Width := ContentW;

  ThemeGap := 16;

  if ContentW > 390 then
  begin
    ThemeButtonW := (ContentW - ThemeGap) / 2;

    btnThemeJapanese.Position.X := Padding;
    btnThemeJapanese.Width := ThemeButtonW;

    d_btnThemeMoonlanding.Position.X := Padding + ThemeButtonW + ThemeGap;
    d_btnThemeMoonlanding.Position.Y := 296;
    d_btnThemeMoonlanding.Width := ThemeButtonW;

    lblSessions.Position.Y := 372;
  end
  else
  begin
    btnThemeJapanese.Position.X := Padding;
    btnThemeJapanese.Width := ContentW;

    d_btnThemeMoonlanding.Position.X := Padding;
    d_btnThemeMoonlanding.Position.Y := 350;
    d_btnThemeMoonlanding.Width := ContentW;

    lblSessions.Position.Y := 426;
  end;

  lblSessions.Position.X := Padding;
  lblSessions.Width := ContentW;

  d_lstSession.Position.X := Padding;
  d_lstSession.Position.Y := lblSessions.Position.Y + 36;
  d_lstSession.Width := ContentW;
  d_lstSession.Height := d_card.Height - d_lstSession.Position.Y - Padding;
end;

constructor TLobbyScreen.Create(AParent: TTabItem);
begin
  inherited Create;
  tbiParent := AParent;
end;

destructor TLobbyScreen.Destroy;
begin
  inherited;
end;

//lobby build
procedure TLobbyScreen.Build;
begin
  rectBackground := TRectangle.Create(tbiParent);
  rectBackground.Parent := tbiParent;
  rectBackground.Align := TAlignLayout.Client;
  rectBackground.Fill.Color := $FF0E2F44;
  rectBackground.Stroke.Kind := TBrushKind.None;
  rectBackground.HitTest := False;

  rectCard := TRectangle.Create(tbiParent);
  rectCard.Parent := tbiParent;
  rectCard.Align := TAlignLayout.Center;
  rectCard.Width := 520;
  rectCard.Height := 520;
  rectCard.XRadius := 28;
  rectCard.YRadius := 28;
  rectCard.Fill.Color := $EE145A45;
  rectCard.Stroke.Color := $FFFF9F1C;
  rectCard.Stroke.Thickness := 3;
  rectCard.HitTest := False;

  lblLobbyTitle := TLabel.Create(rectCard);
  lblLobbyTitle.Parent := rectCard;
  lblLobbyTitle.Text := 'Lobby';
  lblLobbyTitle.Position.X := 62;
  lblLobbyTitle.Position.Y := 60;
  lblLobbyTitle.Width := 420;
  lblLobbyTitle.Height := 44;
  lblLobbyTitle.StyledSettings := [];
  lblLobbyTitle.TextSettings.Font.Size := 30;
  lblLobbyTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblLobbyTitle.TextSettings.FontColor := $FFFFD166;

  lblLobbyPlayers := TLabel.Create(rectCard);
  lblLobbyPlayers.Parent := rectCard;
  lblLobbyPlayers.Text := 'Spelers in deze sessie';
  lblLobbyPlayers.Position.X := 62;
  lblLobbyPlayers.Position.Y := 126;
  lblLobbyPlayers.Width := 300;
  lblLobbyPlayers.Height := 28;
  lblLobbyPlayers.StyledSettings := [];
  lblLobbyPlayers.TextSettings.Font.Size := 17;
  lblLobbyPlayers.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblLobbyPlayers.TextSettings.FontColor := $FFFFFFFF;

  lstLobbyPlayer := TListBox.Create(rectCard);
  lstLobbyPlayer.Parent := rectCard;
  lstLobbyPlayer.Position.X := 62;
  lstLobbyPlayer.Position.Y := 166;
  lstLobbyPlayer.Width := 398;
  lstLobbyPlayer.Height := 250;

  btnBackToHome := TButton.Create(rectCard);
  btnBackToHome.Parent := rectCard;
  btnBackToHome.Text := 'Terug';
  btnBackToHome.Position.X := 62;
  btnBackToHome.Position.Y := 440;
  btnBackToHome.Width := 140;
  btnBackToHome.Height := 44;
  btnBackToHome.StyledSettings := [];
  btnBackToHome.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnBackToHome.TextSettings.FontColor := $FF0B2B18;
end;

procedure TLobbyScreen.Resize;
var
  Padding: Single;
  ContentW: Single;
begin
  if not Assigned(rectCard) then
    Exit;

  Padding := 32;
  ContentW := rectCard.Width - Padding * 2;

  lblLobbyTitle.Position.X := Padding;
  lblLobbyTitle.Width := ContentW;

  lblLobbyPlayers.Position.X := Padding;
  lblLobbyPlayers.Width := ContentW;

  lstLobbyPlayer.Position.X := Padding;
  lstLobbyPlayer.Width := ContentW;
  lstLobbyPlayer.Height := rectCard.Height - 250;

  btnBackToHome.Position.X := Padding;
  btnBackToHome.Position.Y := rectCard.Height - 76;
  btnBackToHome.Width := Min(160, ContentW);
end;

end.
