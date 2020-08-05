unit mainGUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, EditBtn, Types;

type
  //slide solver
       pok=^elem;

   elem=record
    mat:array[1..3,1..3]of integer;
distance:integer;

    sons:array[0..3]of pok;
		otac:pok;
end;

   nizpoteza=array[0..3]of pok;

  pokstack=^elemstack;

 elemstack= record
            info:pok;
            next,prev:pokstack;
end;


 choosematstruct=record
            mat:array[1..9]of integer;
            distance:integer;


 end;


  ////


  { TForm1 }
  matrix=array[1..3,1..3]of integer;

  TForm1 = class(TForm)
    congrats: TImage;
    back: TImage;
    clickcontrol: TImage;
    load1: TShape;
    load2: TShape;
    load3: TShape;
    load4: TShape;
    load5: TShape;
    load6: TShape;
    load7: TShape;
    load8: TShape;
    load9: TShape;
    MenuBackground1: TImage;
    StandardMode: TBitBtn;
    MenuBackground: TImage;
    Label1: TLabel;
    ExceptionalMode: TBitBtn;
    HelpTutorial: TBitBtn;
    StaticnoNumMoves: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    HintDrag: TStaticText;
    copyright: TStaticText;
    timer: TTimer;
    procedure backClick(Sender: TObject);
    procedure congratsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExceptionalModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure HintDragMouseEnter(Sender: TObject);
    procedure HintDragMouseLeave(Sender: TObject);
    procedure MenuBackground1DblClick(Sender: TObject);
    procedure MenuBackground1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuBackground1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuBackgroundClick(Sender: TObject);

    procedure StandardModeClick(Sender: TObject);

    procedure timerTimer(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  pokazivaczaispisresenja:pokstack;
  matrica,resenje,matload:matrix;
  xnull,ynull,numofmoves:integer;
  loadscreen,standard,exp:boolean;
  i,j :integer;
start,finish:pok;
cilj1:array[1..9]of integer=(1,2,3,4,5,6,7,8,0);
cilj2:array[1..9]of integer=(1,4,7,2,5,8,3,6,0);
cilj3:array[1..9]of integer=(4,7,1,5,8,2,6,0,3);


implementation

////////////////////******************************************************
procedure updatecube(matrica:matrix);forward;
function distances(first,second:pok):integer;forward;
procedure choosemat(start,finish:pok);
var nizmatrica:array[0..2]of choosematstruct; //DODAJ USED POLJE KAD GLEDAS SLEDECU FINISH MATRICU
    pomocni:pok;
  i,j,k,mindist,rednibr:integer;
begin
     new(pomocni);
     nizmatrica[0].mat:=cilj1;
   nizmatrica[1].mat:=cilj2;
   nizmatrica[2].mat:=cilj3;
 mindist:=10000000;
   for i:= 0 to 2 do
         begin
         for j:= 1 to 3 do
               for k:= 1 to 3 do
                   pomocni^.mat[j,k]:=nizmatrica[i].mat[(j-1)*3+k];
         nizmatrica[i].distance:=distances(start,pomocni);
         if nizmatrica[i].distance<mindist then
                 begin
                 mindist:= nizmatrica[i].distance;
                 rednibr:=i;
                 end;

         end;
   for j:= 1 to 3 do
               for k:= 1 to 3 do
                   finish^.mat[j,k]:=nizmatrica[rednibr].mat[(j-1)*3+k];

end;


{procedure ispis(start:pok);
var i,j:integer;
begin
     for i:= 0 to 2 do    begin

           for j:= 0 to 2 do
                     case start^.mat[i,j] of
                     1..3:write('1 ');
                     4..6:write('2 ');
                     7,8: write('3 ');
                     0:write('0 ');
                     end;
               writeln() ;
           end;

      writeln() ;
       writeln() ;
        ;


 end; }
function issolved(stanje:pok):boolean;
var ulaz:array[1..3,1..3]of char;
   i,j:integer;
   rows,cols:boolean;
begin
  for i:=1 to 3 do
  for j:= 1 to 3 do
   begin
     if (stanje^.mat[i,j]<=3) then begin
     ulaz[i,j]:='b';
     if stanje^.mat[i,j]=0  then  ulaz[i,j]:='g';
     end
      else if stanje^.mat[i,j]<=6 then ulaz[i,j]:='r'
       else ulaz[i,j]:='g';


    end;
     rows:=true;
       cols:=true;




  for i:=1 to 3 do
  if (ulaz[i,1]<>ulaz[i,2])or (ulaz[i,2]<>ulaz[i,3])then rows:=false;


  for i:=1 to 3 do
  if (ulaz[1,i]<>ulaz[2,i])or (ulaz[2,i]<>ulaz[3,i])then cols:=false;







 issolved:= rows or cols;
end;
//////////////////////POTEZI
function generatemoves(start:pok):nizpoteza;
var potezi:nizpoteza;
      i,j,nulai,nulaj:integer;
begin
      for i:=1 to 3 do
  	for j:=1 to 3 do
 		if (start^.mat[i,j]=0) then
			begin
				nulai:=i;
				nulaj:=j;
			end;

  for i:=0 to 3 do potezi[i]:=nil;

      if(nulaj<>1) then
		begin
			new(potezi[0]);
			potezi[0]^.mat:=start^.mat;
			potezi[0]^.mat[nulai,nulaj]:= potezi[0]^.mat[nulai,nulaj-1];
			potezi[0]^.mat[nulai,nulaj-1]:=0;
			potezi[0]^.otac:=start;
                        for i:=0 to 3 do potezi[0]^.sons[i]:=nil;



		end;

  if(nulaj<>3) then
		begin
			new(potezi[1]);
			potezi[1]^.mat:=start^.mat;
			potezi[1]^.mat[nulai,nulaj]:= potezi[1]^.mat[nulai,nulaj+1];
			potezi[1]^.mat[nulai,nulaj+1]:=0;
			potezi[1]^.otac:=start;
                        for i:=0 to 3 do potezi[1]^.sons[i]:=nil;


		end;

 if(nulai<>1) then
		begin
				new(potezi[2]);
			potezi[2]^.mat:=start^.mat;
			potezi[2]^.mat[nulai,nulaj]:= potezi[2]^.mat[nulai-1,nulaj];
			potezi[2]^.mat[nulai-1,nulaj]:=0;
                                               for i:=0 to 3 do potezi[2]^.sons[i]:=nil;
			potezi[2]^.otac:=start;
		end;
      if(nulai<>3) then
		begin
				new(potezi[3]);
			potezi[3]^.mat:=start^.mat;
			potezi[3]^.mat[nulai,nulaj]:= potezi[3]^.mat[nulai+1,nulaj];
			potezi[3]^.mat[nulai+1,nulaj]:=0;
			potezi[3]^.otac:=start;
                        for i:=0 to 3 do potezi[3]^.sons[i]:=nil;

		end;

 generatemoves:=potezi;
end;
////////////////////////////////////////// HEURISTIKA
function distances(first,second:pok):integer;
var used:array[1..3,1..3]of boolean ;
     i,j,d,l,distance:integer;
     start,finish:pok;
begin
           new(start);
           new(finish);
           start^.mat:=first^.mat;
            finish^.mat:=second^.mat;
		for i:=1 to 3 do
			for j:=1 to 3 do
					begin
				case start^.mat[i,j] of
				1..3 : start^.mat[i,j]:=1;
				4..6 :start^.mat[i,j]:=2;
				0,7..8: start^.mat[i,j]:=3;
				end;

					case finish^.mat[i,j] of
				1..3 : finish^.mat[i,j]:=1;
				4..6 :finish^.mat[i,j]:=2;
				0,7..8: finish^.mat[i,j]:=3;
				end;



				used[i,j]:=false;
 					end;

		distance:=0;


		for i:=1 to 3 do
			for j:=1 to 3 do
			              begin

				d:=1; l:=1;
	      				while(start^.mat[i,j]<>finish^.mat[d,l])or(used[d,l]=true) do
						if l=3 then begin l:=1; d:=d+1 ;end
							else l:=l+1;

					distance:=distance + abs(i-d)+ abs(j-l);
						used[d,l]:=true;



					end ;





	distances:=distance;

end;


{procedure random_init(start:pok); }

{var i,j,k:integer;
  niz:array[1..9] of integer;
begin

     for i:=1 to 9 do niz[i]:=i-1;
    for i:=9 downto 1 do begin k:=random(i)+1; if k=9 then k:=8; j:=niz[i];niz[i]:=niz[k]; niz[k]:=j; end ;
    k:=1;
   for i:=1 to 3 do for j:=1 to 3 do begin start^.mat[i-1,j-1]:=niz[k]; k:=k+1;  end;
end;  }


//////////GENERISAN???

function isgenerated(start,searched:pok):boolean;

var tek:pok;
 stack,disp:pokstack;
flag:boolean;
i,j:integer;

begin

  new(stack);
  stack^.info:=start;
  stack^.prev:=nil;
 stack^.next:=nil;
  flag:=false;
  while (stack<>nil)and not flag do

	 begin
		disp:=stack;
          tek:=stack^.info;
		stack:=stack^.next;
		if stack <> nil then stack^.prev:=nil;

          flag:=true;
	  for i:=1 to 3 do
		for j:=1 to 3 do
			if tek^.mat[i,j]<> searched^.mat[i,j] then flag:=false;

	if not flag then
		begin

		for i:=0 to 3 do if tek^.sons[i]<>nil then
                   if stack<>nil then begin
					new(stack^.prev);
					stack^.prev^.next:=stack;
					stack^.prev^.info:=tek^.sons[i];
					stack:=stack^.prev;
					stack^.prev:=nil;
					end

			else  begin
					 new(stack);
					stack^.info:=tek^.sons[i];
  					stack^.prev:=nil;
 					stack^.next:=nil;
				end;
		end;
	dispose(disp);
	end;



 isgenerated:=flag;

end;


///////////////////////RESAVANJE

procedure solvecube(start,finish:pok);
var tek,next:pok;
	niz:array[0..3]of pok;
flag:boolean;
i,j,nummoves:integer;
front,rear,disp,search,pomoc:pokstack;



begin
  flag:=false;
 // tek:=start;
   new(front);
   front^.next:=nil;
   front^.prev:=nil;
   rear:=front;
   front^.info:=start;
  nummoves:=0;

while not flag and (nummoves<200)do



begin
next:=nil;
   nummoves:=nummoves+1;
   tek:=front^.info;
   disp:=front;
   front:=front^.next;
   if front=nil then rear:=nil;


	niz:=generatemoves(tek);
      for i:=0 to 3 do
		if niz[i]<>nil then
			if isgenerated(start,niz[i]) then niz[i]:=nil
				else
					begin
			niz[i]^.distance:=distances(niz[i],finish);
                        if issolved(niz[i])then begin flag:=true; next:=niz[i];end;
                         search:=front;
                        if front<>nil then
                                begin
                                      while (niz[i]^.distance>=search^.info^.distance)and(search^.next<>nil) do
                                             search:=search^.next;
                                                     //STA SE DESAVA NA KRAJU????

                                                       new(pomoc);
                                                       pomoc^.info:=niz[i];
                                                       if search^.next<>nil then
                                                       pomoc^.next:=search
                                                       else pomoc^.next:=nil;
                                             if search^.next<>nil then begin pomoc^.prev:=search^.prev; search^.prev:=pomoc;

                                                                 if search=front then front:=pomoc;

                                                                 end
                                             else begin

                                               rear^.next:=pomoc;
                                               pomoc^.prev:=rear;

                                               rear:=rear^.next;


                                             end;

                                end
                              else
                                  begin
                                        new(front);
                                        front^.next:=nil;
                                         front^.prev:=nil;
                                          rear:=front;
                                           front^.info:=niz[i];


                                  end;
				{if next<> nil then begin if next^.distance > niz[i]^.distance then next:=niz[i]; end
					else next:=niz[i];}
					end;
         tek^.sons:=niz;
         dispose(disp);

	if next<>nil then tek:=next;

        //ispis(tek);



end;

//ispis stekom
   new(rear);
   rear^.info:=next;
   rear^.next:=nil;
   rear^.prev:=nil;
   next:=next^.otac;

   while(next<>nil)do begin
   new(rear^.prev);
   rear^.prev^.next:=rear;
   rear:=rear^.prev;
   rear^.info:=next;
   rear^.prev:=nil;
   next:=next^.otac;

   end;
  while front<>nil do begin
                    disp:=front; front:=front^.next;
                    dispose(disp);
                    end;
  pokazivaczaispisresenja:=rear;
  Form1.timer.Enabled:=true;

  {while rear<>nil do
        begin
        numofmoves:=numofmoves+1;
        updatecube(rear^.info^.mat);
        ///odlozi na sekund;
        disp:=rear;
        rear:=rear^.next;
        dispose(disp);

        end; }


//while next<>nil do begin ispis(next); next:=next^.otac; end;





end;


procedure solving();
var i,j:integer;

begin
 new(finish);
 new(start);
 for i:= 0 to 3 do start^.sons[i]:=nil;
 start^.otac:=nil;
 start^.mat:=matrica;

 choosemat(start,finish);
solvecube(start,finish);


end;


//////////////////////////*****************************************



























function issolvedmanual(stanje,resenje:matrix):boolean;forward;
procedure updatecube(matrica:matrix);
var i,j:integer;
  niz:array[1..9]of integer;
begin
   for i:= 1 to 3 do
   for j:=1 to 3 do
   niz[(i-1)*3+j]:=matrica[i,j];

   for i:=1 to 9 do
    begin
      case i of
        1:begin
            if niz[1]<=3 then begin
               if niz[1]=0 then begin
                form1.shape1.brush.color:=clLime;
                  form1.shape1.pen.color:=clgreen;
                 form1.shape1.brush.style:=bsBDiagonal;

                end else begin
               form1.shape1.brush.color:=clyellow;
               form1.shape1.brush.style:=bsFDiagonal;
               form1.shape1.pen.color:=clyellow;
               end;
            end
              else if niz[1]<=6 then
                begin
                    form1.shape1.brush.color:=clfuchsia;
               form1.shape1.brush.style:=bsFDiagonal;
                form1.shape1.pen.color:=clfuchsia;
                end
              else begin
                    form1.shape1.brush.color:=clLime;
                    form1.shape1.pen.color:=clLime;
               form1.shape1.brush.style:=bsFDiagonal;

                end;
               end;

      2:begin
            if niz[2]<=3 then begin
               if niz[2]=0 then begin
                form1.shape2.brush.color:=clLime;
                 form1.shape2.brush.style:=bsBDiagonal;
                 form1.shape2.pen.color:=clgreen;

                end else begin
               form1.shape2.brush.color:=clyellow;
               form1.shape2.pen.color:=clyellow;
               form1.shape2.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[2]<=6 then
                begin
                    form1.shape2.brush.color:=clfuchsia;
                    form1.shape2.pen.color:=clfuchsia;
               form1.shape2.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape2.brush.color:=clLime;
                    form1.shape2.pen.color:=clLime;
               form1.shape2.brush.style:=bsFDiagonal;

                end;
               end;


      3:begin
            if niz[3]<=3 then begin
               if niz[3]=0 then begin
                form1.shape3.brush.color:=clLime;
                 form1.shape3.brush.style:=bsBDiagonal;
                 form1.shape3.pen.color:=clgreen;

                end else begin
               form1.shape3.brush.color:=clyellow;
               form1.shape3.brush.style:=bsFDiagonal; form1.shape3.pen.color:=clyellow;
               end;
            end
              else if niz[3]<=6 then
                begin
                    form1.shape3.brush.color:=clfuchsia; form1.shape3.pen.color:=clfuchsia;
               form1.shape3.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape3.brush.color:=clLime;
               form1.shape3.brush.style:=bsFDiagonal;
               form1.shape3.pen.color:=clLime;

                end;
               end;


                  4:begin
            if niz[4]<=3 then begin
               if niz[4]=0 then begin
                form1.shape4.brush.color:=clLime;
                form1.shape4.pen.color:=clgreen;
                 form1.shape4.brush.style:=bsBDiagonal;

                end else begin
               form1.shape4.brush.color:=clyellow;     form1.shape4.pen.color:=clyellow;
               form1.shape4.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[4]<=6 then
                begin
                    form1.shape4.brush.color:=clfuchsia; form1.shape4.pen.color:=clfuchsia;
               form1.shape4.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape4.brush.color:=clLime;
               form1.shape4.brush.style:=bsFDiagonal; form1.shape4.pen.color:=clLime;

                end;
               end;


          5:begin
            if niz[5]<=3 then begin
               if niz[5]=0 then begin
                form1.shape5.brush.color:=clLime;
                 form1.shape5.brush.style:=bsBDiagonal;
                 form1.shape5.pen.color:=clgreen;
                end else begin
               form1.shape5.brush.color:=clyellow;
               form1.shape5.brush.style:=bsFDiagonal;     form1.shape5.pen.color:=clyellow;
               end;
            end
              else if niz[5]<=6 then
                begin
                    form1.shape5.brush.color:=clfuchsia; form1.shape5.pen.color:=clfuchsia;
               form1.shape5.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape5.brush.color:=clLime;    form1.shape5.pen.color:=clLime;
               form1.shape5.brush.style:=bsFDiagonal;

                end;
               end;





                  6:begin
            if niz[6]<=3 then begin
               if niz[6]=0 then begin
                form1.shape6.brush.color:=clLime;
                 form1.shape6.brush.style:=bsBDiagonal;
                   form1.shape6.pen.color:=clgreen;
                end else begin
               form1.shape6.brush.color:=clyellow;
               form1.shape6.brush.style:=bsFDiagonal;   form1.shape6.pen.color:=clyellow;
               end;
            end
              else if niz[6]<=6 then
                begin
                    form1.shape6.brush.color:=clfuchsia;
               form1.shape6.brush.style:=bsFDiagonal;     form1.shape6.pen.color:=clfuchsia;
                end
              else begin
                    form1.shape6.brush.color:=clLime;
               form1.shape6.brush.style:=bsFDiagonal;
                form1.shape6.pen.color:=clLime;
                end;
               end;


                  7:begin
            if niz[7]<=3 then begin
               if niz[7]=0 then begin
                form1.shape7.brush.color:=clLime;
                 form1.shape7.brush.style:=bsBDiagonal;
                  form1.shape7.pen.color:=clgreen;
                end else begin
               form1.shape7.brush.color:=clyellow;        form1.shape7.pen.color:=clyellow;
               form1.shape7.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[7]<=6 then
                begin
                    form1.shape7.brush.color:=clfuchsia;    form1.shape7.pen.color:=clfuchsia;
               form1.shape7.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape7.brush.color:=clLime;
               form1.shape7.brush.style:=bsFDiagonal;
                  form1.shape7.pen.color:=clLime;
                end;
               end;


                   8:begin
            if niz[8]<=3 then begin
               if niz[8]=0 then begin
                form1.shape8.brush.color:=clLime;
                 form1.shape8.brush.style:=bsBDiagonal;
                    form1.shape8.pen.color:=clgreen;
                end else begin
               form1.shape8.brush.color:=clyellow;
               form1.shape8.brush.style:=bsFDiagonal;      form1.shape8.pen.color:=clyellow;
               end;
            end
              else if niz[8]<=6 then
                begin
                    form1.shape8.brush.color:=clfuchsia;
               form1.shape8.brush.style:=bsFDiagonal;    form1.shape8.pen.color:=clfuchsia;
                end
              else begin
                    form1.shape8.brush.color:=clLime;
               form1.shape8.brush.style:=bsFDiagonal;
                     form1.shape8.pen.color:=clLime;
                end;
               end;


                           9:begin
            if niz[9]<=3 then begin
               if niz[9]=0 then begin
                form1.shape9.brush.color:=clLime; form1.shape9.pen.color:=clgreen;
                 form1.shape9.brush.style:=bsBDiagonal;

                end else begin
               form1.shape9.brush.color:=clyellow;      form1.shape9.pen.color:=clyellow;
               form1.shape9.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[9]<=6 then
                begin
                    form1.shape9.brush.color:=clfuchsia; form1.shape9.pen.color:=clfuchsia;
               form1.shape9.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.shape9.brush.color:=clLime;
               form1.shape9.brush.style:=bsFDiagonal;
                      form1.shape9.pen.color:=clLime;
                end;
               end;









    end;



end;
   //if numofmoves=0 then form1.label1.caption:='Number of moves'
   //else
   form1.label1.caption:=InttoStr(numofmoves);
   if standard or exp then
     if issolvedmanual(matrica,resenje) then
              form1.congrats.visible:=true;



end;
procedure updatemenu(matrica:matrix);
var i,j:integer;
  niz:array[1..9]of integer;
begin
   for i:= 1 to 3 do
   for j:=1 to 3 do
   niz[(i-1)*3+j]:=matrica[i,j];

   for i:=1 to 9 do
    begin
      case i of
        1:begin
            if niz[1]<=3 then begin
               if niz[1]=0 then begin
                form1.load1.brush.color:=clBlue;
                 //form1.shape1.brush.style:=bsDiagCross;

                end else begin
               form1.load1.brush.color:=clGreen;
               //form1.shape1.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[1]<=6 then
                begin
                    form1.load1.brush.color:=clRed;
              // form1.shape1.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load1.brush.color:=clBlue;
              // form1.shape1.brush.style:=bsFDiagonal;

                end;
               end;

      2:begin
            if niz[2]<=3 then begin
               if niz[2]=0 then begin
                form1.load2.brush.color:=clBlue;
                 //form1.shape2.brush.style:=bsBDiagonal;

                end else begin
               form1.load2.brush.color:=clGreen;
               //form1.load2.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[2]<=6 then
                begin
                    form1.load2.brush.color:=clRed;
               //form1.shape2.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load2.brush.color:=clBlue;
               //form1.shape2.brush.style:=bsFDiagonal;

                end;
               end;


      3:begin
            if niz[3]<=3 then begin
               if niz[3]=0 then begin
                form1.load3.brush.color:=clBlue;
                 //form1.shape3.brush.style:=bsBDiagonal;

                end else begin
               form1.load3.brush.color:=clGreen;
              // form1.shape3.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[3]<=6 then
                begin
                    form1.load3.brush.color:=clRed;
               //*form1.shape3.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load3.brush.color:=clBlue;
               //form1.shape3.brush.style:=bsFDiagonal;

                end;
               end;


                  4:begin
            if niz[4]<=3 then begin
               if niz[4]=0 then begin
                form1.load4.brush.color:=clBlue;
                 //form1.shape4.brush.style:=bsBDiagonal;

                end else begin
               form1.load4.brush.color:=clGreen;
               //form1.shape4.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[4]<=6 then
                begin
                    form1.load4.brush.color:=clRed;
             //  form1.shape4.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load4.brush.color:=clblue;
               //form1.shape4.brush.style:=bsFDiagonal;

                end;
               end;


          5:begin
            if niz[5]<=3 then begin
               if niz[5]=0 then begin
                form1.load5.brush.color:=clblue;
                // form1.shape5.brush.style:=bsBDiagonal;

                end else begin
               form1.load5.brush.color:=clgreen;
               //form1.shape5.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[5]<=6 then
                begin
                    form1.load5.brush.color:=clRed;
               //form1.shape5.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load5.brush.color:=clblue;
              // form1.shape5.brush.style:=bsFDiagonal;

                end;
               end;





                  6:begin
            if niz[6]<=3 then begin
               if niz[6]=0 then begin
                form1.load6.brush.color:=clblue;
                 //form1.shape6.brush.style:=bsBDiagonal;

                end else begin
               form1.load6.brush.color:=clgreen;
               //form1.shape6.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[6]<=6 then
                begin
                    form1.load6.brush.color:=clRed;
               //form1.shape6.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load6.brush.color:=clgreen;
               //form1.shape6.brush.style:=bsFDiagonal;

                end;
               end;


                  7:begin
            if niz[7]<=3 then begin
               if niz[7]=0 then begin
                form1.load7.brush.color:=clblue;
                 //form1.shape7.brush.style:=bsBDiagonal;

                end else begin
               form1.load7.brush.color:=clgreen;
               //form1.shape7.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[7]<=6 then
                begin
                    form1.load7.brush.color:=clRed;
               //form1.shape7.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load7.brush.color:=clblue;
               ///form1.shape7.brush.style:=bsFDiagonal;

                end;
               end;


                   8:begin
            if niz[8]<=3 then begin
               if niz[8]=0 then begin
                form1.load8.brush.color:=clblue;
                 //form1.shape8.brush.style:=bsBDiagonal;

                end else begin
               form1.load8.brush.color:=clgreen;
               //form1.shape8.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[8]<=6 then
                begin
                    form1.load8.brush.color:=clRed;
               //form1.shape8.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load8.brush.color:=clblue;
               //form1.shape8.brush.style:=bsFDiagonal;

                end;
               end;


                           9:begin
            if niz[9]<=3 then begin
               if niz[9]=0 then begin
                form1.load9.brush.color:=clblue;
                 //form1.shape9.brush.style:=bsBDiagonal;

                end else begin
               form1.load9.brush.color:=clgreen;
               //form1.shape9.brush.style:=bsFDiagonal;
               end;
            end
              else if niz[9]<=6 then
                begin
                    form1.load9.brush.color:=clRed;
               //form1.shape9.brush.style:=bsFDiagonal;
                end
              else begin
                    form1.load9.brush.color:=clblue;
               //form1.shape9.brush.style:=bsFDiagonal;

                end;
               end;









    end;



end;
   //if numofmoves=0 then form1.label1.caption:='Number of moves'
   //else
   form1.label1.caption:=InttoStr(numofmoves);


end;
procedure StandardSolution(var matrica:matrix);
var i,j:integer;

begin
for i:=1 to 3 do
for j:=1 to 3 do
   matrica[i,j]:= (i-1)*3+j;
matrica[3,3]:=0;


end;
procedure randominit(var matrica:matrix;var x,y:integer);
var i,j,k:integer;
  niz:array[1..9] of integer;
begin
   //randomize();

     for i:=1 to 9 do niz[i]:=i-1;
    for i:=9 downto 1 do begin k:=random(i)+1; if k=10 then k:=9; j:=niz[i];niz[i]:=niz[k]; niz[k]:=j; end ;
    k:=1;
   for i:=1 to 3 do for j:=1 to 3 do begin
     matrica[i,j]:=niz[k]; k:=k+1;
     if matrica[i,j]=0 then begin
      x:=i;
      y:=j;

     end;
   end;
end;





procedure moveup(var matrica:matrix;var x,y:integer);
begin
  if x<>1 then begin
     matrica[x,y]:=matrica[x-1,y];
     matrica[x-1,y]:=0;
     numofmoves:=numofmoves+1;
     x:=x-1;
  end;
 end;
procedure movedown(var matrica:matrix;var x,y:integer);
begin
  if x<>3 then begin
     matrica[x,y]:=matrica[x+1,y];
     matrica[x+1,y]:=0;
     numofmoves:=numofmoves+1;
     x:=x+1;
  end;
 end;
procedure moveleft(var matrica:matrix;var x,y:integer);
begin
  if y<>1 then begin
     matrica[x,y]:=matrica[x,y-1];
     matrica[x,y-1]:=0;
     numofmoves:=numofmoves+1;
     y:=y-1;
  end;
 end;
procedure moveright(var matrica:matrix;var x,y:integer);
begin
  if y<>3 then begin
     matrica[x,y]:=matrica[x,y+1];
     matrica[x,y+1]:=0;
     numofmoves:=numofmoves+1;
     y:=y+1;
  end;
 end;
{$R *.lfm}

{ TForm1 }




procedure menuonoff(flag:boolean);
begin
     randomize();
  loadscreen:=flag;
  form1.standardmode.visible:=flag;
  form1.exceptionalmode.visible:=flag;;
  form1.helptutorial.visible:=flag;
  form1.menubackground.visible:=flag;
  form1.load1.visible:=flag;
   form1.load2.visible:=flag;
    form1.load3.visible:=flag;
     form1.load4.visible:=flag;
      form1.load5.visible:=flag;
       form1.load6.visible:=flag;
        form1.load7.visible:=flag;
         form1.load8.visible:=flag;
          form1.load9.visible:=flag;
         form1.staticnonummoves.Visible:=not flag;

       if flag then
          form1.HintDrag.Caption:='';


end;





procedure TForm1.FormCreate(Sender: TObject);
begin
  randomize();
  randominit(matrica,xnull,ynull);
  loadscreen:=true;
  //updatemenu(matrica);
  numofmoves:=0;
  form1.hintdrag.caption:='';
end;
procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
  if (button=mbLeft) and not loadscreen then begin
     moveleft(matrica,xnull,ynull);
     updatecube(matrica);

  end;
end;
procedure TForm1.MenuBackground1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
      if (button=mbLeft) and not loadscreen then begin
     moveleft(matrica,xnull,ynull);
     updatecube(matrica);

  end;
end;
procedure TForm1.MenuBackground1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
       if (button=mbRight) and not loadscreen then begin
     moveright(matrica,xnull,ynull);
     updatecube(matrica);

  end;
end;

procedure TForm1.MenuBackgroundClick(Sender: TObject);
begin

end;



procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (button=mbRight) and not loadscreen then begin
     moveright(matrica,xnull,ynull);
     updatecube(matrica);

  end;

end;
procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if  not loadscreen then begin
  movedown(matrica,xnull,ynull);
  updatecube(matrica);
  end;
end;
procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if not loadscreen then begin

  moveup(matrica,xnull,ynull);
  updatecube(matrica);
end;
end;
procedure TForm1.HintDragMouseEnter(Sender: TObject);
var temp1,temp2:boolean;
begin
   temp1:=standard;
   standard:=false;
   temp2:=exp;
   exp:=false;
  updatecube(resenje);

    standard:=temp1;
    exp:=temp2;
end;
procedure TForm1.HintDragMouseLeave(Sender: TObject);
begin
  updatecube(matrica);
end;

procedure TForm1.MenuBackground1DblClick(Sender: TObject);
begin
  if standard then
  solving();
end;





procedure TForm1.StandardModeClick(Sender: TObject);
begin

           menuonoff(false);
          form1.hintdrag.caption:='Drag for goal  ';
          standard:=true;
          randominit(matrica,xnull,ynull);
          standardsolution(resenje);
          updatecube(matrica);
          numofmoves:=0;


end;



procedure TForm1.timerTimer(Sender: TObject);
var disp:pokstack;
begin
  if pokazivaczaispisresenja<>nil then
  begin

        numofmoves:=numofmoves+1;
        updatecube(pokazivaczaispisresenja^.info^.mat);
        ///odlozi na sekund;
        disp:=pokazivaczaispisresenja;
        pokazivaczaispisresenja:=pokazivaczaispisresenja^.next;
        dispose(disp);




  end else begin timer.Enabled:=false;  numofmoves:=0; end;

end;

function issolvedmanual(stanje,resenje:matrix):boolean;
var ulaz,izlaz:array[1..3,1..3]of char;
   i,j:integer;
   rows,cols:boolean;
begin
  for i:=1 to 3 do
  for j:= 1 to 3 do
   begin
     if (stanje[i,j]<=3) then begin
     ulaz[i,j]:='b';
     if stanje[i,j]=0  then  ulaz[i,j]:='g';
     end
      else if stanje[i,j]<=6 then ulaz[i,j]:='r'
       else ulaz[i,j]:='g';

       if (resenje[i,j]<=3) then begin
     izlaz[i,j]:='b';
     if resenje[i,j]=0  then  izlaz[i,j]:='g';
     end
      else if resenje[i,j]<=6 then izlaz[i,j]:='r'
       else izlaz[i,j]:='g';
    end;
     rows:=true;
       cols:=true;

 if standard then begin


  for i:=1 to 3 do
  if (ulaz[i,1]<>ulaz[i,2])or (ulaz[i,2]<>ulaz[i,3])then rows:=false;


  for i:=1 to 3 do
  if (ulaz[1,i]<>ulaz[2,i])or (ulaz[2,i]<>ulaz[3,i])then cols:=false;




end;

 if exp then begin

     for  i:=1 to 3 do
     for  j:=1 to 3 do begin
         if ulaz[j,i]<>izlaz[j,i]then cols:=false;
        if ulaz[i,j]<>izlaz[i,j]then rows:=false;
     end;


 end;
 issolvedmanual:= rows or cols;
end;





//exceptional
procedure TForm1.ExceptionalModeClick(Sender: TObject);
var x,y:integer;
begin
         menuonoff(false);
          form1.hintdrag.caption:='Drag for goal  ';
          exp:=true;
          randominit(matrica,xnull,ynull);
          randominit(resenje,x,y);
          numofmoves:=0;
          updatecube(matrica);







end;

procedure TForm1.congratsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  loadscreen:=true;
  menuonoff(true);
  standard:=false;
  exp:=false;
  form1.congrats.Visible:=false;
end;

procedure TForm1.backClick(Sender: TObject);
begin
  loadscreen:=true;
  menuonoff(true);
   standard:=false;
  exp:=false;

end;




end.

