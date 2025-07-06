import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/models/user_balance.dart';
import 'package:saku_tani_mobile/providers/shares_provider.dart';

import '../../components/summary_cards.dart';

class SharesScreen extends StatefulWidget {
  @override
  _SharesScreenState createState() => _SharesScreenState();
}

class _SharesScreenState extends State<SharesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SharesProvider>(context, listen: false).loadUserBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bagi Hasil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFF43F5E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<SharesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.userBalances.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                SummaryCard(
                  title: provider.zakatBalance.userName,
                  value: provider.formatCurrency(provider.zakatBalance.balance),
                  color: Color(0xFFF43F5E),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: provider.otherUserBalances.map((user) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: SummaryCard(
                        title: user.userName,
                        value: provider.formatCurrency(user.balance),
                        color: Color(0xFF10B981),
                        textColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
