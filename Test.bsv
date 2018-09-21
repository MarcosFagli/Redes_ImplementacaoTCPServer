import GetPut::*;
import FIFOF::*;
import StmtFSM::*;

typedef Bit#(8) Byte;

typedef union tagged {
	Byte Dado;
	void NovaConexao;
	void ConexaoFechada;
} TCP2App deriving (Eq, Bits, FShow);

typedef union tagged {
	Byte Dado;
	void FecharConexao;
} App2TCP deriving (Eq, Bits, FShow);

interface App;
	interface Put#(TCP2App) fromTCP;
	interface Get#(App2TCP) toTCP;
endinterface

module mkApp(App);
	FIFOF#(TCP2App) fromTCPq <- mkFIFOF;
	FIFOF#(App2TCP) toTCPq <- mkFIFOF;

	FIFOF#(Byte) caminho <- mkSizedFIFOF(32);

	Maybe#(Byte) byteAtual = case (fromTCPq.first) matches
		tagged Dado .d: tagged Valid d;
		default: tagged Invalid;
	endcase;

	Bool espaco = fromMaybe(0, byteAtual) == fromInteger(charToInteger(" "));
	Bool cr = fromMaybe(0, byteAtual) == 13;			//carriage return
	Bool lf = fromMaybe(0, byteAtual) == 10;			//line feed

	Reg#(Bit#(1)) newline_count <- mkReg(?);
	Reg#(Bit#(6)) newchar_count <- mkReg(?);
	Reg#(Bit#(32)) i <- mkReg(?);


	String txt = "HTTP/1.0 200 OK\nContent-Type: text/html\n\n<!DOCTYPE html>\n<html>\n<head>\n<h1>\n";
	String txt_sucesso = "Ola \"<i>";
	String txt_bad = "O caminho tem que ter menos que 32 caracteres";
	String closeTagi = "</h1>\n</i>\n</head>\n<html>";

	mkAutoFSM(seq
		while (True) seq
			await(fromTCPq.first == NovaConexao);
			fromTCPq.deq;
			newline_count <= 0;
			newchar_count <= 0;

			while (!espaco)
				fromTCPq.deq;

			fromTCPq.deq;

			while (!espaco && newchar_count < 32)
				action
					caminho.enq(fromMaybe(0, byteAtual));
					newchar_count <= newchar_count + 1;
					fromTCPq.deq;
				endaction

			while (!(lf && newline_count == 1))
				action
					if (lf)
						newline_count <= newline_count + 1;
					else if (!cr)
						newline_count <= 0;
					fromTCPq.deq;
				endaction

			if(newchar_count == 32)

				par
					seq
						while (fromTCPq.first != ConexaoFechada)
							fromTCPq.deq;

						fromTCPq.deq;
					endseq

					seq
						i <= 0;
						while(i < fromInteger(stringLength(txt))) action
							toTCPq.enq(tagged Dado fromInteger(charToInteger(txt[i])));
							i <= i+1;
						endaction

						i <= 0;
						while(i < fromInteger(stringLength(txt_bad))) action
							toTCPq.enq(tagged Dado fromInteger(charToInteger(txt_bad[i])));
							i <= i+1;
						endaction
						
						caminho.clear;


						toTCPq.enq(tagged FecharConexao);
					endseq
				endpar

			else

				$display("%d", newchar_count);
				par
					seq
						while (fromTCPq.first != ConexaoFechada)
							fromTCPq.deq;

						fromTCPq.deq;
					endseq

					seq

						i <= 0;
						while(i < fromInteger(stringLength(txt))) action
							toTCPq.enq(tagged Dado fromInteger(charToInteger(txt[i])));
							i <= i+1;
						endaction

						i <= 0;
						while(i < fromInteger(stringLength(txt_sucesso))) action
							toTCPq.enq(tagged Dado fromInteger(charToInteger(txt_sucesso[i])));
							i <= i+1;
						endaction
						caminho.deq;

						while (caminho.notEmpty)
							seq
								toTCPq.enq(tagged Dado caminho.first);
								$display("%c", caminho.first);
								caminho.deq;
							endseq

						i <= 0;
						while(i < fromInteger(stringLength(closeTagi))) action
							toTCPq.enq(tagged Dado fromInteger(charToInteger(closeTagi[i])));
							i <= i+1;
						endaction

						toTCPq.enq(tagged FecharConexao);
					endseq

				endpar
		endseq
	endseq);

	interface fromTCP = toPut(fromTCPq);
	interface toTCP = toGet(toTCPq);
endmodule

import "BDPI" function ActionValue#(Bit#(32)) socket_get();
import "BDPI" function Action socket_put(Bit#(32) val);

(* synthesize *)
module mkTest();
	App app <- mkApp;

	rule socket2app;
		let val <- socket_get;
		case (val[9:8]) matches
			// 2'b00: nada aconteceu
			2'b01: app.fromTCP.put(tagged Dado val[7:0]);
			2'b10: app.fromTCP.put(NovaConexao);
			2'b11: app.fromTCP.put(ConexaoFechada);
		endcase
	endrule

	rule app2socket;
		let data <- app.toTCP.get;
		let val = case (data) matches
			tagged Dado .d: {1'b0, d};
			FecharConexao:  {1'b1, 8'b0};
		endcase;
		socket_put(zeroExtend(val));
	endrule
endmodule